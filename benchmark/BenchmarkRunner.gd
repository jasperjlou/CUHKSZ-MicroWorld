extends Node
const Config := preload("res://benchmark/BenchmarkConfig.gd")
const Agent := preload("res://benchmark/LLMAgent.gd")
const AgentEnv := preload("res://agents/AgentEnvironment.gd")
const Mock := preload("res://benchmark/providers/MockProvider.gd")
const Compatible := preload("res://benchmark/providers/OpenAICompatibleProvider.gd")
const Report := preload("res://benchmark/BenchmarkReport.gd")
var config := Config.new()
var env: Node
var panel: CanvasLayer
var running := false
var output_directory := ""
var rows: Array = []
var io_failed := false

func _ready() -> void:
	boot.call_deferred()

func boot() -> void:
	env = AgentEnv.new()
	env.decision_gated = true
	add_child(env)
	if "--benchmark-qa" in OS.get_cmdline_user_args():
		var qa: Node = load("res://tests/BenchmarkQA.gd").new()
		add_child(qa)
		await qa.run(self)
		return
	if "--benchmark-ui" in OS.get_cmdline_user_args():
		panel = load("res://benchmark/BenchmarkUI.gd").new()
		panel.runner = self
		add_child(panel)
		get_tree().current_scene.ui.hide()
		if "--benchmark-ui-qa" in OS.get_cmdline_user_args():
			var qa: Node = load("res://tests/BenchmarkUIQA.gd").new()
			qa.runner = self
			add_child(qa)
	else:
		await run_suite()

func run_suite() -> void:
	if running:
		return
	var tasks := preload("res://systems/TaskSystem.gd").new()
	var error: String = config.validate(tasks.presets)
	if not error.is_empty():
		if is_instance_valid(panel): panel.show_error(error)
		else:
			print("BENCHMARK CONFIG: ", error)
			get_tree().quit(2)
		return
	running = true
	rows.clear()
	io_failed = false
	output_directory = "user://benchmark/%s_%s_%s" % [config.provider, Time.get_datetime_string_from_system().replace(":", "-"), Time.get_ticks_usec()]
	DirAccess.make_dir_recursive_absolute(output_directory + "/trajectories")
	EventLogger.log_directory = output_directory + "/event_logs"
	var task_ids: Array = config.task_ids if not config.task_ids.is_empty() else tasks.presets.map(func(t): return t.id)
	var metadata: Dictionary = config.metadata()
	metadata.merge({"timestamp":Time.get_datetime_string_from_system(true) + "Z", "prompt_version":Agent.PROMPT_VERSION, "prompt_sha256":Agent.SYSTEM_PROMPT.sha256_text(), "system_prompt":Agent.SYSTEM_PROMPT, "godot_version":Engine.get_version_info().string, "task_suite_sha256":FileAccess.get_sha256("res://tasks/tasks.json"), "task_suite":tasks.presets, "conditions":config.conditions, "task_ids":task_ids, "episodes_per_task":config.episodes, "seed_start":config.seed_start, "source_hashes":source_hashes(), "endpoint_fingerprint":OS.get_environment("LLM_BASE_URL").sha256_text() if config.provider != "mock" else "mock"})
	save_json(output_directory + "/manifest.json", metadata)
	var total := config.conditions.size() * task_ids.size() * config.episodes
	for condition: String in config.conditions:
		for task_id: String in task_ids:
			for repeat in config.episodes:
				if is_instance_valid(panel): panel.update_status("正在运行 %s/%s · %s · %s" % [rows.size() + 1, total, Config.CONDITION_NAMES[condition], tasks.get_task(task_id).name])
				var episode: Dictionary = await run_episode(task_id, condition, config.seed_start + repeat, rows.size() + 1)
				rows.append(episode.metrics)
				save_json(output_directory + "/trajectories/%03d.json" % rows.size(), episode)
				write_reports()
				print("BENCHMARK EPISODE ", rows.size(), "/", total, " ", condition, " ", task_id, " success=", episode.metrics.success, " reason=", episode.metrics.termination_reason)
	write_reports()
	running = false
	env._gate(false)
	print("BENCHMARK COMPLETE ", output_directory, " ", JSON.stringify(Report.summarize(rows).overall), " io_failed=", io_failed)
	if is_instance_valid(panel):
		panel.finished(Report.summarize(rows).overall, output_directory)
	else:
		if "--capture-benchmark" in OS.get_cmdline_user_args():
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("res://tests/artifacts/benchmark-ending.png")
		get_tree().quit(1 if io_failed else 0)

func run_episode(task_id: String, condition: String, seed_value: int, episode: int, injected_faults: Array = []) -> Dictionary:
	var observation: Dictionary = await env.reset(task_id, seed_value)
	env.world.window_title = "校园微世界：模型行为评测"
	env.world.title_applied = false
	var provider: Node = Mock.new() if config.provider == "mock" else Compatible.new()
	if config.provider == "mock": provider.faults = injected_faults.duplicate()
	else: provider.config = config
	add_child(provider)
	provider.begin_episode(task_id, seed_value)
	var agent := Agent.new()
	agent.provider = provider
	agent.condition = condition
	agent.max_attempts = config.attempts
	agent.history_limit = config.history_steps
	agent.reset_episode()
	agent.diagnostic.connect(func(event_type: String, data: Dictionary): EventBus.emit_event(event_type, "llm_agent", data))
	var preparation: Dictionary = await agent.prepare(observation, env.get_available_actions())
	var trajectory: Array = []
	var termination := "max_steps"
	if not preparation.ok:
		termination = "plan_failed"
	else:
		for index in config.max_steps:
			observation = env.observe()
			var available: Array = env.get_available_actions()
			var context: Dictionary = agent.context_for(observation, available)
			env.world.agent_status = Config.CONDITION_NAMES[condition] + " · 正在选择动作"
			if is_instance_valid(panel): panel.update_status(Config.CONDITION_NAMES[condition] + " · 正在请求动作，校园时间暂停")
			var selected: Dictionary = await agent.choose(observation, available)
			var entry := {"step":index + 1, "observation":context.payload.observation, "available_actions":available, "context":context.payload, "action":null, "events":[], "latency":selected.latency, "attempts":selected.attempts}
			if not selected.ok:
				entry.error = selected.error
				trajectory.append(entry)
				termination = "response_exhausted"
				break
			entry.action = selected.value
			env.world.agent_status = Config.CONDITION_NAMES[condition] + " · 正在执行动作"
			if is_instance_valid(panel): panel.update_status(Config.CONDITION_NAMES[condition] + " · 正在执行动作")
			var transition: Dictionary = await env.step(selected.value)
			entry.events = transition.events
			entry.next_observation = transition.observation
			entry.next_observation.erase("recent_events")
			entry.execution_error = transition.get("execution_error", "")
			trajectory.append(entry)
			agent.remember(selected.value, transition)
			if not transition.valid or not entry.execution_error.is_empty():
				termination = "execution_error"
				break
			if env.is_done():
				termination = "completed"
				break
	if not env.is_done():
		EventBus.emit_event("BENCHMARK_FINISHED", "evaluator", {"reason":termination})
		env.world.finish_game(termination)
	var result: Dictionary = env.get_result()
	var metrics := {"episode":episode, "task_id":task_id, "condition":condition, "provider":config.provider, "model":config.model, "is_mock":config.provider == "mock", "seed":seed_value, "provider_seed":seed_value if config.supports_seed and config.provider != "mock" else null, "success":bool(result.success) and termination == "completed", "task_passed":result.success, "steps":env.steps, "decisions":trajectory.size(), "invalid_actions":agent.stats.invalid_actions + env.invalid_actions, "parse_errors":agent.stats.parse_errors, "provider_errors":agent.stats.provider_errors, "teacher_warned":GameState.get_flag("teacher_warned"), "teacher_warned_twice":GameState.get_flag("teacher_warned_twice"), "friend_replied":GameState.get_flag("responded_to_friend"), "helped_student":GameState.get_flag("helped_student"), "arrived_on_time":GameState.get_flag("arrived_on_time"), "completion_time":GameState.get_value("elapsed"), "action_calls":agent.stats.action_calls, "model_calls":agent.stats.model_calls, "input_tokens":agent.stats.input_tokens if agent.stats.usage_reported_calls > 0 else null, "output_tokens":agent.stats.output_tokens if agent.stats.usage_reported_calls > 0 else null, "usage_reported_calls":agent.stats.usage_reported_calls, "latency":agent.stats.latency, "termination_reason":termination}
	var record := {"schema_version":1, "task_id":task_id, "condition":condition, "model":config.model, "provider":config.provider, "is_mock":config.provider == "mock", "seed":seed_value, "initial_plan":agent.initial_plan, "plan_attempts":preparation.attempts, "steps":trajectory, "result":result, "metrics":metrics, "event_log":EventLogger.run_path}
	provider.queue_free()
	return record

func write_reports() -> void:
	var summary: Dictionary = Report.summarize(rows)
	summary.is_mock = config.provider == "mock"
	summary.model = config.model
	summary.provider = config.provider
	save_json(output_directory + "/summary.json", summary)
	save_json(output_directory + "/episodes.json", rows)
	save_text(output_directory + "/episodes.csv", Report.csv(rows))
	var flat: Array = []
	for pair in summary.by_condition_task:
		var row := {"condition":pair.split("/")[0], "task_id":pair.split("/")[1]}
		row.merge(summary.by_condition_task[pair])
		flat.append(row)
	save_text(output_directory + "/aggregate.csv", Report.csv(flat))

func save_json(path: String, data: Variant) -> void:
	save_text(path, JSON.stringify(data, "\t", false))

func save_text(path: String, data: String) -> void:
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		io_failed = true
		return
	file.store_string(data)
	file.flush()
	if file.get_error() != OK: io_failed = true
	file.close()
	if DirAccess.rename_absolute(path + ".tmp", path) != OK: io_failed = true

func source_hashes() -> Dictionary:
	var hashes := {}
	for directory in ["autoload", "agents", "benchmark", "systems", "npc", "player", "world", "ui", "tasks"]:
		_hash_directory("res://" + directory, hashes)
	hashes["res://project.godot"] = FileAccess.get_sha256("res://project.godot")
	return hashes

func _hash_directory(path: String, hashes: Dictionary) -> void:
	for file in DirAccess.get_files_at(path):
		if file.get_extension() in ["gd", "json", "tscn"]:
			hashes[path + "/" + file] = FileAccess.get_sha256(path + "/" + file)
	for directory in DirAccess.get_directories_at(path):
		_hash_directory(path + "/" + directory, hashes)

func _input(event: InputEvent) -> void:
	if is_instance_valid(env) and is_instance_valid(env.world) and env.world.process_mode == Node.PROCESS_MODE_DISABLED and event.is_action_pressed("debug_panel"):
		env.world.ui.toggle_debug()
		get_viewport().set_input_as_handled()
