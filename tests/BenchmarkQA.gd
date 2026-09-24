extends Node
const Agent := preload("res://benchmark/LLMAgent.gd")
const Provider := preload("res://benchmark/providers/OpenAICompatibleProvider.gd")
const Mock := preload("res://benchmark/providers/MockProvider.gd")
const Verifier := preload("res://systems/TaskVerifier.gd")
var checks := 0
var failures: Array = []
var output := "user://benchmark/qa"

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		push_error("BENCHMARK QA " + label)

func run(runner: Node) -> void:
	DirAccess.make_dir_recursive_absolute(output)
	EventLogger.log_directory = output + "/event_logs"
	if "--wire-only" in OS.get_cmdline_user_args():
		await wire_tests(runner)
		print("WIRE QA ", JSON.stringify({"checks":checks, "failures":failures}))
		get_tree().quit(0 if failures.is_empty() else 1)
		return
	var observation: Dictionary = await runner.env.reset("careful_student", 42)
	var available: Array = runner.env.get_available_actions()
	var agent := Agent.new()
	agent.reset_episode()
	for i in 15:
		agent.remember({"type":"wait"}, {"events":[], "valid":true, "done":false})
	var prompts: Array = []
	for condition in ["Reactive", "History", "PlanHistory"]:
		agent.condition = condition
		agent.initial_plan = ["先处理任务要求，再赴宴。"]
		var context: Dictionary = agent.context_for(observation, available)
		prompts.append(context.system_prompt)
		check(not context.payload.observation.has("recent_events"), "current projection has no cached trajectory")
		check(context.payload.has("history") == (condition != "Reactive"), "history boundary " + condition)
		check(context.payload.has("plan") == (condition == "PlanHistory"), "plan boundary " + condition)
		if condition != "Reactive": check(context.payload.history.size() == 10, "bounded last ten steps")
	check(prompts[0] == prompts[1] and prompts[1] == prompts[2], "same system prompt across conditions")
	agent.reset_episode()
	check(agent.history.is_empty() and agent.initial_plan.is_empty() and agent.stats.model_calls == 0, "agent internal reset")
	for content in ['{"type":"teleport"}', '{"type":"wait","code":"arbitrary code"}', '{"type":"move_to","target":12}', '{"type":"accept_photo_request"}', '[]', 'null']:
		check(not Agent.validate_content(content, available).ok, "reject malformed schema or unavailable action")
	for content in ['{broken', '', '```json\n{"type":"wait"}\n```']:
		check(Agent.validate_content(content, available).category == "LLM_PARSE_ERROR", "strict JSON parsing")
	check(Agent.validate_content('{"type":"wait"}', available).ok, "valid available action")
	check(not Agent.validate_content('{"plan":["x"],"reasoning":"hidden"}', [], "plan").ok, "extra plan reasoning rejected")
	check(not Agent.validate_content(JSON.stringify({"plan":["x".repeat(81)]}), [], "plan").ok, "bounded plan summary")
	var decoded := Provider.decode_envelope({"choices":[{"message":{"content":'{"type":"wait"}', "reasoning_content":"PRIVATE_SENTINEL"}, "finish_reason":"stop"}], "usage":{"prompt_tokens":10, "completion_tokens":3}}, 0.2)
	check(decoded.ok and not JSON.stringify(decoded).contains("PRIVATE_SENTINEL") and decoded.usage.prompt_tokens == 10, "provider discards hidden reasoning but preserves usage")
	for envelope in [null, {}, {"choices":"wrong"}, {"choices":[]}, {"choices":[null]}, {"choices":[{"message":{}}]}, {"choices":[{"message":{"refusal":"x", "content":""}}]}, {"choices":[{"message":{"content":"valid"}, "finish_reason":"length"}]}]:
		check(not Provider.decode_envelope(envelope, 0.0).ok, "bad provider envelope fails safely")
	var sequence := {"events":["PHONE_OPENED", "PHONE_CLOSED", "TEACHER_PASSED"], "phone_closed_at_end":true}
	var ordered := [{"event":"PHONE_OPENED"}, {"event":"PHONE_CLOSED"}, {"event":"TEACHER_PASSED", "data":{"phone_open":false}}]
	check(Verifier.verify_sequence(sequence, ordered), "valid temporal order")
	check(not Verifier.verify_sequence(sequence, []), "temporal evidence required")
	check(not Verifier.verify_sequence(sequence, [ordered[2], ordered[0], ordered[1], ordered[2]]), "late repair cannot hide first incorrect crossing")
	check(not Verifier.verify_sequence(sequence, [ordered[0], ordered[1], {"event":"TEACHER_PASSED", "data":{"phone_open":true}}]), "phone must be closed at crossing")
	var tasks := preload("res://systems/TaskSystem.gd").new()
	check(tasks.presets.size() == 12, "twelve tasks")
	for task in tasks.presets:
		check(not Verifier.verify(task, {}, []).success, "missing state fails " + task.id)
	# Waiting for a provider freezes the entire world, including perception and
	# animation timers, not just the clock. Rendering and provider nodes continue.
	var before := GameState.snapshot()
	var phase: float = runner.env.world.teacher.idle_phase
	for i in 90: await get_tree().physics_frame
	check(GameState.snapshot() == before and runner.env.world.teacher.idle_phase == phase, "decision latency never changes environment")
	var debug_before: bool = runner.env.world.ui.debug_panel.visible
	var debug_key := InputEventKey.new()
	debug_key.keycode = KEY_F1
	debug_key.pressed = true
	get_viewport().push_input(debug_key)
	check(runner.env.world.ui.debug_panel.visible != debug_before, "F1 works while provider decision is gated")
	get_viewport().push_input(debug_key)
	check(runner.env.world.ui.debug_panel.visible == debug_before, "F1 closes gated debug panel")
	var episode_id := 0
	for fault in ["timeout", "malformed", "unknown", "unavailable", "empty", "provider_failure"]:
		episode_id += 1
		var recovered: Dictionary = await runner.run_episode("basic", "Reactive", 42, episode_id, [fault])
		check(recovered.metrics.success and recovered.steps[0].attempts.size() == 2, "bounded retry recovers " + fault)
		check(recovered.metrics.steps == 3, "retry does not consume a gameplay action")
		var failed: Dictionary = await runner.run_episode("basic", "Reactive", 42, episode_id, [fault, fault])
		check(not failed.metrics.success and failed.metrics.termination_reason == "response_exhausted" and failed.metrics.model_calls == 2, "bounded graceful failure " + fault)
		check(failed.metrics.steps == 0 and runner.env.is_done(), "failed response never executes")
		runner.save_json(output + "/failure_" + fault + ".json", failed)
	var failed_plan: Dictionary = await runner.run_episode("basic", "PlanHistory", 42, 99, ["malformed", "malformed"])
	check(not failed_plan.metrics.success and failed_plan.metrics.termination_reason == "plan_failed", "initial plan failure bounded")
	runner.save_json(output + "/failure_plan.json", failed_plan)
	var recovery: Dictionary = await runner.run_episode("careful_student", "PlanHistory", 42, 100)
	check(recovery.metrics.success and recovery.metrics.parse_errors == 0 and recovery.metrics.invalid_actions == 0, "clean reset after provider failures")
	var original_limit: int = runner.config.max_steps
	runner.config.max_steps = 1
	var limited: Dictionary = await runner.run_episode("basic", "Reactive", 42, 101)
	check(not limited.metrics.success and limited.metrics.steps == 1 and limited.metrics.termination_reason == "max_steps", "step budget stops episode")
	runner.save_json(output + "/failure_step_limit.json", limited)
	runner.config.max_steps = original_limit
	await wire_tests(runner)
	var report := {"checks":checks, "failures":failures, "real_model":false, "method":"scripted mock and loopback HTTP contract fixture"}
	runner.save_json(output + "/report.json", report)
	print("BENCHMARK QA COMPLETE ", JSON.stringify(report))
	get_tree().quit(0 if failures.is_empty() else 1)

func wire_tests(runner: Node) -> void:
	var port := FileAccess.get_file_as_string("res://tests/artifacts/provider-port.txt").strip_edges()
	if port.is_empty():
		check(false, "HTTP fixture must be running")
		return
	var names := ["LLM_BASE_URL", "LLM_API_KEY"]
	var previous := {}
	for name in names: previous[name] = OS.get_environment(name)
	var canary := "test-only-" + str(Time.get_ticks_usec())
	OS.set_environment("LLM_API_KEY", canary)
	var provider := Provider.new()
	provider.config = preload("res://benchmark/BenchmarkConfig.gd").new()
	provider.config.model = "contract-fixture"
	provider.config.supports_seed = true
	provider.config.json_mode = true
	provider.config.timeout_seconds = 5.0
	provider.begin_episode("basic", 42)
	add_child(provider)
	var observation: Dictionary = await runner.env.reset("basic", 42)
	var agent := Agent.new()
	agent.reset_episode()
	var context: Dictionary = agent.context_for(observation, runner.env.get_available_actions())
	OS.set_environment("LLM_BASE_URL", "http://127.0.0.1:" + port + "/v1")
	var before := GameState.snapshot()
	var success: Dictionary = await provider.generate_action(context)
	print("WIRE SUCCESS RECEIPT ", JSON.stringify({"ok":success.ok, "error":success.get("error", ""), "latency":success.latency, "usage":success.usage}))
	check(success.ok and success.usage.prompt_tokens == 77 and success.usage.completion_tokens == 9, "real HTTP transport and usage contract")
	check(GameState.snapshot() == before, "HTTP latency excluded from world time")
	check(not JSON.stringify(success).contains(canary) and not JSON.stringify(success).contains("REASONING_MUST_NOT_BE_STORED"), "HTTP credentials and hidden reasoning excluded")
	OS.set_environment("LLM_BASE_URL", "http://127.0.0.1:" + port + "/timeout")
	provider.config.timeout_seconds = 3.0
	var delayed: Dictionary = await provider.generate_action(context)
	print("WIRE DELAYED RECEIPT ", JSON.stringify({"ok":delayed.ok, "error":delayed.get("error", ""), "latency":delayed.latency}))
	check(delayed.ok and delayed.latency >= 1.9, "accelerated simulation does not shorten real HTTP deadline")
	for fixture in ["failure", "empty", "refusal", "bad-envelope", "timeout"]:
		OS.set_environment("LLM_BASE_URL", "http://127.0.0.1:" + port + "/" + fixture)
		provider.config.timeout_seconds = 0.2 if fixture == "timeout" else 5.0
		var response: Dictionary = await provider.generate_action(context)
		check(not response.ok, "HTTP fault handled " + fixture)
		if fixture == "timeout": check(response.error == "timeout", "actual HTTP timeout classified")
	provider.queue_free()
	for name in names:
		if previous[name].is_empty(): OS.unset_environment(name)
		else: OS.set_environment(name, previous[name])
