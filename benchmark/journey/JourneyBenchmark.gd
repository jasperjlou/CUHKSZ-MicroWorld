extends Node
const PublicView := preload("res://benchmark/journey/JourneyObservation.gd")
const Verifier := preload("res://benchmark/journey/JourneyVerifier.gd")
var world: Node
var job: Dictionary
var task: Dictionary
var agent: RefCounted
var trajectory: FileAccess
var termination := ""
var action_count := 0
var sim_start := 0.0
var running := false
var invalid_outputs := 0

func _ready() -> void:
	job = preload("res://benchmark/journey/JourneyTask.gd").load_job()
	task = job.task
	call_deferred("run")

func _physics_process(_delta: float) -> void:
	if running and not world.finished and WorldTime.current_time-sim_start >= task.max_simulated_duration:
		termination = "simulation_timeout"
		world.finish_task(false,false)

func run() -> void:
	seed(int(job.seed))
	EventLogger.log_directory = job.output_dir+"/events"
	trajectory = FileAccess.open(job.output_dir+"/trajectory.jsonl",FileAccess.WRITE)
	if trajectory == null:
		get_tree().quit(2)
		return
	world.ui.hide()
	DisplayServer.window_set_title("校园微世界：智能体评测")
	world.start()
	world.ui.hide()
	sim_start = WorldTime.current_time
	running = true
	for _i in range(5):
		await get_tree().physics_frame
	# Every setup disturbance is physically executed and separately attributed.
	for action: Dictionary in task.setup_actions:
		var before := PublicView.observe(world,task)
		var response: Dictionary = await world.environment_api.step(action)
		write_step("setup",before,[],action,response,{})
		if not response.ok:
			termination = "setup_failed"
			break
	var provider: Node
	if job.provider == "mock":
		provider = preload("res://benchmark/journey/JourneyMockProvider.gd").new()
	elif job.provider == "replay":
		provider = preload("res://benchmark/journey/JourneyReplayProvider.gd").new()
		provider.actions = job.replay_actions
		provider.plan = job.replay_plan
	else:
		provider = preload("res://benchmark/providers/OpenAICompatibleProvider.gd").new()
		var config := preload("res://benchmark/BenchmarkConfig.gd").new()
		config.model = job.model
		config.max_tokens = int(job.max_tokens)
		config.timeout_seconds = float(job.request_timeout)
		config.temperature = float(job.temperature)
		config.supports_seed = job.supports_seed
		config.json_mode = job.json_mode
		config.token_parameter = job.token_parameter
		provider.config = config
	add_child(provider)
	provider.begin_episode(task.task_id,int(job.seed))
	agent = preload("res://benchmark/journey/JourneyAgent.gd").new()
	agent.provider = provider
	agent.condition = job.condition
	agent.history_limit = int(job.history_steps)
	agent.max_attempts = int(job.attempts)
	agent.reset_episode()
	GameState.set_flag("paused",true)
	var prepared: Dictionary = await agent.prepare(PublicView.observe(world,task),PublicView.actions(world,task))
	trajectory.store_line(JSON.stringify({"kind":"plan","condition":job.condition,"plan":agent.initial_plan,"receipts":prepared.attempts}))
	GameState.set_flag("paused",false)
	if not prepared.ok:
		termination = "provider_plan_failure"
	for index in range(int(task.max_steps)):
		if world.finished or not termination.is_empty():
			break
		var before := PublicView.observe(world,task)
		var legal := PublicView.actions(world,task)
		GameState.set_flag("paused",true)
		var context: Dictionary = agent.context_for(before,legal)
		var selected: Dictionary = await agent.choose(before,legal)
		GameState.set_flag("paused",false)
		if not selected.ok:
			termination = "provider_action_failure"
			write_step("agent",before,legal,{}, {"ok":false,"reason":selected.error},context,selected.attempts)
			break
		var action: Dictionary = selected.value
		action_count += 1
		var response: Dictionary = await world.environment_api.step(action)
		write_step("agent",before,legal,action,response,context,selected.attempts)
		agent.remember_step(before,action,{"ok":response.ok,"reason":response.get("reason",""),"observation":PublicView.observe(world,task)})
	if not world.finished and termination.is_empty():
		termination = "step_limit"
	running = false
	GameState.set_flag("paused",true)
	var state := Verifier.snapshot(world,task)
	state.invalid_actions += int(agent.stats.invalid_actions)
	var result := Verifier.evaluate(state,task,termination)
	var metrics: Dictionary = world.journey_metrics()
	result.merge(world.transport.metrics())
	result.merge(metrics,true)
	var usage_complete: bool = agent.stats.model_calls > 0 and agent.stats.usage_reported_calls == agent.stats.model_calls and job.provider == "openai-compatible"
	result.merge({"schema_version":"journey-result-v1","run_id":job.run_id,"task_id":task.task_id,"category":task.category,"condition":job.condition,"provider":job.provider,"model":job.model,"seed":job.seed,"action_count":action_count,"invalid_actions":state.invalid_actions,"invalid_model_outputs":agent.stats.invalid_actions,"model_calls":agent.stats.model_calls,"provider_errors":agent.stats.provider_errors,"path_length":world.travelled,"path_length_unit":"game_units","time_unit":"game_seconds","simulated_duration":WorldTime.current_time-sim_start,"prompt_tokens":agent.stats.input_tokens if usage_complete else null,"completion_tokens":agent.stats.output_tokens if usage_complete else null,"total_tokens":agent.stats.input_tokens+agent.stats.output_tokens if usage_complete else null,"latency_ms":agent.stats.latency*1000 if job.provider == "openai-compatible" else null,"trajectory_path":"trajectory.jsonl","environment_version":"v1.0.0-rc1","baseline_commit":"71fe452","suite_version":job.suite_version,"task_sha256":job.task_sha256,"source_commit":job.source_commit,"environment_sha256":job.environment_sha256,"configuration":job.run_config,"is_mock":job.provider == "mock","evidence_kind":job.run_config.get("evidence_kind","mock"),"setup_action_count":task.setup_actions.size(),"arrival_time_text":GameState.format_time(float(result.arrival_time),true) if result.arrival_time != null else null})
	trajectory.store_line(JSON.stringify({"kind":"verdict","state":state,"result":result}))
	trajectory.flush()
	trajectory.close()
	if not world.finished:
		world.finish_task(false,false)
	var file := FileAccess.open(job.output_dir+"/result.json",FileAccess.WRITE)
	if file == null or EventLogger.io_error:
		print("JOURNEY BENCHMARK IO FAILURE")
		get_tree().quit(2)
		return
	file.store_string(JSON.stringify(result,"  "))
	file.close()
	print("JOURNEY BENCHMARK COMPLETE ",JSON.stringify({"task_id":task.task_id,"condition":job.condition,"success":result.success,"failure_reason":result.failure_reason}))
	get_tree().quit(0)

func write_step(actor: String, before: Dictionary, legal: Array, action: Dictionary, response: Dictionary, context: Dictionary, receipts: Array = []) -> void:
	var after := PublicView.observe(world,task)
	var record := {"kind":"step","actor":actor,"step_index":action_count,"simulated_time":WorldTime.current_time,"current_zone":after.current_zone,"nearest_landmark":after.nearest_landmark,"observation":before,"legal_actions":legal,"action":action,"action_result":{"ok":response.ok,"reason":response.get("reason","")},"next_observation":after,"transport_state":after.shuttle,"event_state":after.event_status,"branch_decision":action.get("target",null),"replanning_count":world.journey_metrics().replanning_count,"verifier_state":Verifier.snapshot(world,task),"provider_context":context,"receipts":receipts}
	trajectory.store_line(JSON.stringify(record))
	trajectory.flush()
