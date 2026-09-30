extends Node
const Agent := preload("res://benchmark/journey/JourneyAgent.gd")
const PublicView := preload("res://benchmark/journey/JourneyObservation.gd")
const Verifier := preload("res://benchmark/journey/JourneyVerifier.gd")
var world: Node
var checks := 0
var failures: Array = []

func _ready() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		print("RC1 FAIL: ",label)

func run() -> void:
	var task: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://benchmark/tasks/journey-v1/time_early.json"))
	world.start()
	GameState.set_flag("paused",true)
	var observation := PublicView.observe(world,task)
	var legal := PublicView.actions(world,task)
	for forbidden in ["correct_route","best_branch","shortest_path","verifier","task_config","setup_actions","future_states","ground_context","task_result","journey","known_landmarks","visited_zones"]:
		check(not observation.has(forbidden),"projection excludes "+forbidden)
	check(not legal.is_empty(),"legal actions exist")
	check(not legal.has({"type":"board","shuttle_id":"prototype_shuttle_01"}),"cannot board away from stop")
	check(not legal.has({"type":"navigate","target":"VehicleRoad_Direction"}),"vehicle road not navigable")
	for condition in ["Reactive","History","PlanHistory"]:
		var agent := Agent.new()
		agent.condition = condition
		agent.history_limit = 2
		agent.reset_episode()
		for i in range(5):
			agent.remember_step({"marker":i},{"type":"wait","duration":30},{"ok":true})
		check(agent.history.size() == 2,"bounded history "+condition)
		agent.initial_plan = ["查看当前任务，再选择行动。"]
		var context := agent.context_for(observation,legal)
		check(context.payload.has("history") == (condition != "Reactive"),"history condition "+condition)
		check(context.payload.has("plan") == (condition == "PlanHistory"),"plan condition "+condition)
		check(context.payload.observation == observation,"same current projection "+condition)
		context.payload.observation.current_task.description = "tampered"
		check(observation.current_task.description == task.instruction,"context is deep copy "+condition)
		check(agent._validate(JSON.stringify(legal[0]),legal,"action").ok,"legal choice accepted "+condition)
		for bad in ['{"type":"teleport"}','{"type":"wait","duration":-1}','{"type":"wait","duration":30,"success":true}','{"type":"navigate","target":"VehicleRoad_Direction"}','not json']:
			check(not agent._validate(bad,legal,"action").ok,"invalid response rejected "+condition+bad)
		check(not agent._validate('{"plan":["short"],"reasoning":"secret"}',legal,"plan").ok,"reasoning field forbidden "+condition)
		agent.reset_episode()
		check(agent.history.is_empty() and agent.initial_plan.is_empty() and agent.stats.model_calls == 0,"episode reset "+condition)
	var state := {"distance_to_destination":0.2,"inspected_destination":true,"arrival_time":66500.0,"completed_visits":["FairyLake_Viewpoint_01"],"invalid_actions":0,"recovery_count":0,"transport":{"shuttle_used":false}}
	check(Verifier.evaluate(state,task,"").success,"independent success")
	for pair in [[66500.0,"early"],[66560.0,"on_time"],[66600.0,"on_time"],[66600.2,"late"],[67800.0,"missed"]]:
		state.arrival_time = pair[0]
		var verdict := Verifier.evaluate(state,task,"")
		check(verdict.event_state == pair[1],"event boundary "+str(pair))
		check(verdict.success == (pair[1] in ["early","on_time"]),"deadline verdict "+str(pair))
	state.arrival_time = 66500.0
	for field in ["distance_to_destination","inspected_destination","completed_visits","invalid_actions","recovery_count"]:
		var copy := state.duplicate(true)
		copy[field] = {"distance_to_destination":9.0,"inspected_destination":false,"completed_visits":[],"invalid_actions":1,"recovery_count":1}[field]
		check(not Verifier.evaluate(copy,task,"").success,"reject manipulated state "+field)
	for reason in ["step_limit","simulation_timeout","provider_action_failure"]:
		check(not Verifier.evaluate(state,task,reason).success,"terminal failure "+reason)
	world.result.success = true
	check(not Verifier.evaluate(Verifier.snapshot(world,task),task,"").success,"world or agent success assertion is not authoritative")
	var start_time: float = WorldTime.current_time
	for _i in range(60):
		await get_tree().physics_frame
	check(WorldTime.current_time == start_time,"decision wait freezes simulation")
	GameState.set_flag("paused",false)
	var rejected: Dictionary = await world.environment_api.step({"type":"teleport","target":"UpperCampus_Start"})
	check(not rejected.ok and world.invalid_actions == 1,"actual runtime rejects invalid action")
	var first: Dictionary = PublicView.observe(world,task)
	first.current_task.required_visits.clear()
	check(not task.required_visits.is_empty(),"projection cannot change required visits")
	world.finish_task(false,false)
	print("RC1 CONTRACT QA ",JSON.stringify({"checks":checks,"failures":failures}))
	get_tree().quit(0 if failures.is_empty() else 1)
