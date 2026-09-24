extends Node
const AgentEnv :=  preload("res://agents/AgentEnvironment.gd")
const Rule := preload("res://agents/RuleBasedAgent.gd")
const RandomPolicy := preload("res://agents/RandomAgent.gd")
const Text := preload("res://systems/ChineseText.gd")
const ACTION_NAMES := {"move_to":"步行前往", "talk_to":"交谈", "open_phone":"拿出手机", "close_phone":"收起手机", "reply_to_friend":"回复朋友", "accept_photo_request":"帮忙拍照", "decline_photo_request":"婉拒拍照", "enter_high_table":"进入高桌晚宴", "continue_dialogue":"结束交谈", "wait":"稍作停留"}
var env: Node
var failures: Array = []
var checks := 0
var session_directory := ""
var captured_photo := false
var captured_walk := false

func _ready() -> void:
	run.call_deferred()

func run() -> void:
	env = AgentEnv.new()
	add_child(env)
	EventLogger.log_directory = "user://evaluation/event_logs"
	session_directory = "user://evaluation/session_%s_%s" % [Time.get_datetime_string_from_system().replace(":", "-"), OS.get_process_id()]
	DirAccess.make_dir_recursive_absolute(session_directory)
	if "--agent-qa" in OS.get_cmdline_user_args():
		var qa: Node = load("res://tests/AgentQA.gd").new()
		add_child(qa)
		await qa.run(env)
		return
	var demo := "--agent-demo" in OS.get_cmdline_user_args()
	var names: Array = ["rule_based"] if demo else ["rule_based", "random"]
	for agent_name: String in names:
		var policy = Rule.new() if agent_name == "rule_based" else RandomPolicy.new()
		env.episode_reset.connect(policy.reset_episode)
		var episodes: Array = []
		for episode in (1 if demo else 20):
			var observation: Dictionary = await env.reset("careful_student", 1000 + episode)
			env.world.window_title = "校园微世界：规则策略演示" if demo else "校园微世界：程序评测"
			env.world.title_applied = false
			_check_reset(episode)
			var trajectory: Array = []
			var execution_errors := 0
			for step_number in 100:
				var actions: Array = env.get_available_actions()
				var action: Dictionary = policy.choose(observation, actions)
				check(not action.is_empty(), "policy has an available action")
				env.world.agent_status = ("规则策略" if agent_name == "rule_based" else "随机策略") + " · " + _action_label(action)
				var event_start := EventLogger.events.size()
				var response: Dictionary = await env.step(action)
				if not response.get("execution_error", "").is_empty():
					execution_errors += 1
				trajectory.append({"step":step_number + 1, "observation":observation, "action":action, "events":response.events, "event_log_sequences":EventLogger.events.slice(event_start).map(func(e): return e.sequence), "response":response})
				check(response.valid, "sampled action valid")
				observation = response.observation
				if env.is_done():
					break
			var truncated: bool = not env.is_done()
			if truncated:
				EventBus.emit_event("AGENT_EPISODE_TRUNCATED", "agent", {"max_steps":100})
				env.world.finish_game("step_limit")
			var metrics := _metrics(episode + 1, trajectory.size(), truncated, execution_errors)
			check(execution_errors == 0, "no blocked navigation")
			check(not EventLogger.io_error, "event log saved")
			check(env.world.last_result == env.world.tasks.evaluate(), "shared verifier final result")
			if agent_name == "rule_based":
				check(metrics.success and metrics.invalid_actions == 0, "rule completes Task C")
			var path := session_directory + "/%s_%02d_trajectory.json" % [agent_name, episode + 1]
			metrics["trajectory"] = path
			_save(path, {"schema_version":1, "agent":agent_name, "task_id":"careful_student", "seed":1000 + episode, "steps":trajectory, "result":env.get_result(), "metrics":metrics, "event_log":EventLogger.run_path})
			episodes.append(metrics)
			print("AGENT EPISODE ", agent_name, " ", episode + 1, " ", JSON.stringify(metrics))
		var summary := _summarize(agent_name, episodes)
		_save("user://evaluation/%s_%s_runs.json" % [agent_name, episodes.size()], summary)
		_save(session_directory + "/%s_summary.json" % agent_name, summary)
		print("AGENT SUMMARY ", JSON.stringify(summary.aggregate))
		env.episode_reset.disconnect(policy.reset_episode)
	_save(session_directory + "/checks.json", {"checks":checks, "failures":failures})
	print("AGENT CHECKS ", checks, " failures=", failures.size())
	if demo:
		env.world.agent_status = "规则策略 · 本局完成"
		if "--capture-agent" in OS.get_cmdline_user_args():
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("res://tests/artifacts/agent-ending.png")
			get_tree().quit(0 if failures.is_empty() else 1)
	else:
		get_tree().quit(0 if failures.is_empty() else 1)

func _check_reset(episode: int) -> void:
	check(not GameState.get_flag("phone_open") and not GameState.get_flag("helped_student") and not GameState.get_flag("teacher_warned") and not GameState.get_flag("responded_to_friend"), "reset flags %s" % episode)
	check(env.world.player.position.distance_to(Vector3(0, 0.1, 49.6)) < 0.2, "reset player position")
	check(env.world.player.navigation_direction == Vector2.ZERO and not env.world.player.photo_mode, "reset navigation camera")
	check(env.world.dialogue_options.is_empty() and env.world.last_result.is_empty(), "reset dialogue verifier")
	check(env.world.teacher.pending_warning == 0 and not env.world.teacher.closed_since_warning and env.world.student.photo_remaining == 0 and not env.world.friend.greeted, "reset NPC temporal state")
	check(GameState.get_value("elapsed") < 0.05 and env.steps == 0 and env.invalid_actions == 0, "reset clock counters")
	check(EventLogger.events.size() == 3 and EventLogger.events[0].sequence == 1, "new log starts with three initial events")

func _metrics(episode: int, count: int, truncated: bool, execution_errors: int) -> Dictionary:
	# Privileged evaluator boundary: never passed back into either policy.
	return {"episode":episode, "task_id":"careful_student", "success":bool(env.get_result().success) and not truncated, "steps":count, "invalid_actions":env.invalid_actions, "teacher_warned":GameState.get_flag("teacher_warned"), "helped_student":GameState.get_flag("helped_student"), "arrived_on_time":GameState.get_flag("arrived_on_time"), "completion_time":GameState.get_value("elapsed"), "total_events":EventLogger.events.size(), "second_warning":GameState.get_flag("teacher_warned_twice"), "friend_replied":GameState.get_flag("responded_to_friend"), "truncated":truncated, "execution_errors":execution_errors}

func _summarize(agent_name: String, episodes: Array) -> Dictionary:
	var success := 0
	var invalid := 0
	var total_steps := 0
	var duration := 0.0
	for row in episodes:
		success += int(row.success)
		invalid += row.invalid_actions
		total_steps += row.steps
		duration += row.completion_time
	return {"agent":agent_name, "task_id":"careful_student", "seed_start":1000, "max_steps":100, "aggregate":{"episodes":episodes.size(), "success":success, "failure":episodes.size() - success, "invalid_actions":invalid, "average_steps":float(total_steps) / episodes.size(), "average_completion_time":duration / episodes.size()}, "episodes":episodes}

func _action_label(action: Dictionary) -> String:
	var label: String = ACTION_NAMES.get(action.get("type", ""), "等待动作")
	var target: String = action.get("target", "")
	return label + " " + Text.LOCATIONS.get(target, {"teacher_01":"老师", "photo_student":"拍照同学", "friend_01":"朋友"}.get(target, ""))

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures.append(message)
		push_error("AGENT QA: " + message)

func _save(path: String, data: Variant) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	check(file != null, "open evaluation file")
	if file:
		file.store_string(JSON.stringify(data, "\t", false))
		file.close()

func _process(_delta: float) -> void:
	if "--capture-agent" not in OS.get_cmdline_user_args() or not is_instance_valid(env) or not is_instance_valid(env.world):
		return
	if not captured_photo and env.world.player.photo_mode:
		captured_photo = true
		_capture("agent-photo")
	if not captured_walk and env.world.player.moving and env.world.player.position.z < 10:
		captured_walk = true
		_capture("agent-walk")

func _capture(filename: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://tests/artifacts/" + filename + ".png")
