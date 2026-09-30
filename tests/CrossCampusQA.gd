extends "res://tests/JunctionQA.gd"
const Policy := preload("res://agents/CrossCampusPolicy.gd")
var runs: Array = []

func fresh(scenario: String = "shuttle_faster") -> void:
	monitor = false
	world.restart()
	await frames(10)
	world = get_tree().current_scene
	check(world.full_journey and world.elapsed == 0 and world.completed_visits.is_empty() and world.visited_zones.is_empty() and world.wrong_branch_count == 0 and world.branch_replanning_count == 0 and world.walking_time == 0,"restart clears journey state")
	check(not world.transport.riding and not world.transport.waiting and not world.transport.shuttle_used and world.events.is_empty() and world.result.is_empty(),"restart clears transport results and logs")
	check(world.player.position.distance_to(J.point("UpperBranch_End")) < 0.3,"restart uses actual upper campus anchor")
	world.transport.configure(scenario)
	await click_button("从上园出发")
	check(GameState.get_flag("started") and GameState.can_move(),"start UI actually unlocks movement")
	if not GameState.can_move():
		print("START_DIAGNOSTIC ",GameState.snapshot())
		await capture("phase-f-start-failed")
		get_tree().quit(1)
		return
	monitor = true

func policy_finish(label: String) -> void:
	var policy := Policy.new()
	for _i in range(8):
		if world.finished:
			break
		var action := policy.decide(world.environment_api.observe())
		var response: Dictionary = await world.environment_api.step(action)
		check(response.ok,"observation-only policy action "+label+" "+str(action))
		if not response.ok:
			var blockers: Array = []
			for i in world.player.get_slide_collision_count():
				blockers.append(str(world.player.get_slide_collision(i).get_collider().get_path()))
			print("POLICY_DIAGNOSTIC ",world.player.position," ",blockers)
			break
	check(world.finished,"policy terminates "+label)
	if not world.finished:
		return
	check(world.result.required_visits_complete and world.result.destination == "LowerCampus_Event_Area","new destination verifier includes lake waypoint "+label)
	for key: String in ["success","arrival_time","lateness","path_length","walking_time","waiting_time","shuttle_used","transport_mode","wrong_branch_count","replanning_count","invalid_actions","visited_zones"]:
		check(world.result.has(key),"benchmark metric "+key)
	check(world.recovery_count == 0 and world.result.invalid_actions == 0,"clean physical journey "+label)
	var summary: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(EventLogger.summary_path))
	check(summary.result.success == world.result.success and summary.result.destination == world.result.destination and absf(summary.result.path_length-world.result.path_length) < 0.001 and absf(summary.result.arrival_time-world.result.arrival_time) < 0.001,"benchmark persisted with exact result "+label)
	var entry: Dictionary = world.result.duplicate(true)
	entry.case = label
	runs.append(entry)
	ui_audit(world.ui.root)

func run() -> void:
	reparent(get_tree().root)
	Engine.set_meta("cross_campus_qa_running",true)
	render = "--cross-campus-render" in OS.get_cmdline_user_args()
	if render:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	await frames(8)
	print("PHYSICS_SETTING ",ProjectSettings.get_setting("physics/3d/physics_engine"))
	check(str(ProjectSettings.get_setting("physics/3d/physics_engine","DEFAULT")) in ["DEFAULT","GodotPhysics3D"],"physics backend unchanged")
	check(world.full_journey and world.task_config.baseline == "560a898da54cdb2852c463fabae6b41f92bcb062","Phase E comparison baseline anchored")
	check(world.task_config.legacy_models_imported == 0,"no legacy models imported")
	check(geometry_is_traceable(world.builder.get_node("JourneyDestinationSlices")),"all new visible and collision geometry carries provenance")
	for record: Dictionary in world.Journey.objects():
		check(world.builder.semantic_nodes[record.id].get_meta("semantic") == world.records[record.id],"destination geometry and observation agree")
	var initial: Dictionary = world.environment_api.observe()
	check(initial.destination_confidence == "inferred" and initial.event.confidence == "placeholder","geometry confidence distinct from fictional event")
	check(initial.nearest_landmark == "UpperCampus_Start" and initial.location.semantic_path == "UpperCampus_Start","new anchor owns location semantics")
	initial.junction_branches[0].target = "corrupt"
	check(world.environment_api.observe().junction_branches[0].target == "UpperCampus_Start","journey branch observations are isolated copies")
	check(world.transport.walking_eta() > world.path_graph.distance(world.player.position,J.point("LowerBranch_End"))/world.player.WALK_SPEED*WorldTime.time_scale,"walking estimate includes outstanding lake stop")
	await capture("phase-f-intro")
	ui_audit(world.ui.root)
	await click_button("从上园出发")
	check(GameState.get_flag("started") and GameState.can_move(),"start UI actually unlocks movement")
	if not GameState.can_move():
		print("START_DIAGNOSTIC ",GameState.snapshot())
		await capture("phase-f-start-failed")
		get_tree().quit(1)
		return
	monitor = true
	await frames(5)
	check(world.environment_api.observe().current_zone == "ZONE_UPPER_CAMPUS","upper start zone active")
	await capture("phase-f-upper-start")
	await press_physical(KEY_F1)
	await frames(4)
	check(world.ui.debug.text.contains("上园出发广场") and world.ui.debug.text.contains("可替换"),"F1 reports actual upper anchor confidence")
	await capture("phase-f-upper-confidence")
	await press_physical(KEY_F1)
	# Traverse the complete route using held player input, not agent steering or teleport.
	for waypoint: Vector3 in world.path_graph.route(world.player.position,world.Layout.position_of(world.records["FairyLake_Viewpoint_01"])):
		await walk_to(waypoint)
	check("FairyLake_Viewpoint_01" in world.completed_visits,"physical human-input route reaches lake")
	await capture("phase-f-lake-visit")
	for waypoint: Vector3 in world.path_graph.route(world.player.position,J.point("LowerBranch_End")):
		await walk_to(waypoint)
	await frames(5)
	check(world.environment_api.observe().current_zone == "ZONE_LOWER_CAMPUS","lower event zone active")
	await capture("phase-f-lower-arrival")
	await press_physical(KEY_E)
	check(world.finished and world.result.success,"held-input upper lake lower completes event")
	runs.append(world.result.duplicate(true))
	await capture("phase-f-walk-ending")
	# Second full playable route: policy uses observation only after a wrong turn.
	await fresh()
	await navigate("LingCollege_Approach")
	await press_physical(KEY_C)
	await capture("phase-f-ling-landmark")
	await press_physical(KEY_C)
	check(world.wrong_branch_count == 1,"alternative college destination counted once")
	check(Policy.new().decide(world.environment_api.observe()).get("target","") == "FirstJunction","policy independently recognizes alternative endpoint and returns to junction")
	await policy_finish("ling_replan")
	check(world.result.replanning_count == 1 and world.result.wrong_branch_count == 1,"physical return from college records replan")
	check(world.events.any(func(e: Dictionary): return e.event == "JOURNEY_REPLAN" and e.data.at == "CollegeBranch_Fork"),"replan log names actual return fork")
	await capture("phase-f-replan-ending")
	if render:
		get_window().size = Vector2i(960,640)
		await frames(8)
		ui_audit(world.ui.root)
		check(find_button(world.ui.root,"重新从上园出发").get_global_rect().end.y <= world.ui.root.size.y,"ending buttons fit minimum resolution")
		await capture("phase-f-ending-960")
		monitor = false
		check(bad_floor == 0 and world.recovery_count == 0,"two rendered journeys grounded with finite cameras")
		write_report()
		return
	# Inspecting old test endpoint cannot finish the new task; reverse journey stays walkable.
	await fresh()
	await navigate("LowerCampus_Event_Area")
	await navigate("UpperCampus_Start")
	check(not world.finished,"lower to upper reverse route")
	await navigate("OtherBranch_End")
	check(world.wrong_branch_count == 1,"other branch mismatch")
	await navigate("LowerCampus_Direction")
	check(world.interact("LowerCampus_Direction") and not world.finished,"old endpoint is no longer event destination")
	await policy_finish("other_replan_reverse")
	check(world.result.wrong_branch_count == 1 and world.result.replanning_count == 1,"other branch recovery recorded")
	# Genuine wait/board journey after visiting the lake.
	await fresh()
	await navigate("FairyLake_Viewpoint_01")
	await navigate(world.transport.STOP_ID)
	var wait_seconds: float = maxf(0.1,world.transport.shuttle.actual_arrival-WorldTime.current_time+1)
	var response: Dictionary = await world.environment_api.step({"type":"wait","duration":wait_seconds})
	check(response.ok,"wait until scheduled shuttle")
	response = await world.environment_api.step({"type":"board","shuttle_id":world.transport.shuttle.definition.id})
	check(response.ok and world.transport.riding,"board existing shuttle system")
	await capture("phase-f-shuttle")
	var walking_before: float = world.travelled
	response = await world.environment_api.step({"type":"wait","duration":240})
	check(response.ok and not world.transport.riding,"shuttle arrives at actual lower plaza")
	check(absf(world.travelled-walking_before) < 0.5,"abstract ride excluded from walking distance")
	await policy_finish("shuttle")
	check(world.result.shuttle_used and world.result.success and world.result.waiting_time > 0,"shuttle is viable for full journey")
	await capture("phase-f-shuttle-ending")
	# Delayed transport can be abandoned; no new time or event system.
	await fresh("delayed")
	await navigate("FairyLake_Viewpoint_01")
	await navigate(world.transport.STOP_ID)
	response = await world.environment_api.step({"type":"wait","duration":30})
	response = await world.environment_api.step({"type":"continue_walking","reason":"预计接驳较晚，改为步行"})
	check(response.ok and world.transport.replanning_count == 1,"delay wait to walk replanning")
	await policy_finish("delay_walk")
	# Late and missed outcomes advance the actual WorldTime through wait actions.
	for outcome: String in ["late","missed"]:
		await fresh()
		await navigate("FairyLake_Viewpoint_01")
		await navigate("LowerCampus_Event_Area")
		var deadline: float = world.task_config.event.start_time if outcome == "late" else world.task_config.event.end_time
		while WorldTime.current_time <= deadline:
			response = await world.environment_api.step({"type":"wait","duration":minf(1800,deadline-WorldTime.current_time+1)})
			check(response.ok,"real clock wait for "+outcome)
		await policy_finish(outcome)
		check(world.result.arrival_status == outcome and not world.result.success,"correct "+outcome+" event result")
	# Restart while waiting and while riding as well as from the two anchor areas.
	await fresh()
	await navigate(world.transport.STOP_ID)
	world.transport.choice("wait","重开检查")
	await fresh()
	await navigate(world.transport.STOP_ID)
	response = await world.environment_api.step({"type":"wait","duration":maxf(1,world.transport.shuttle.actual_arrival-WorldTime.current_time+1)})
	response = await world.environment_api.step({"type":"board","shuttle_id":world.transport.shuttle.definition.id})
	check(response.ok,"board before mid-ride reset")
	await fresh()
	var observation: Dictionary = world.environment_api.observe()
	check(observation.junction_branches.size() == 5 and not observation.has("best_branch") and not observation.has("correct_route"),"branch semantics retained without route oracle")
	response = await world.environment_api.step({"type":"navigate","target":"Junction_VehicleRoad"})
	check(not response.ok,"vehicle road remains non-walkable")
	await navigate("LowerCampus_Event_Area")
	world.interact("LowerCampus_Event_Area")
	check(world.finished and not world.result.success and not world.result.required_visits_complete,"skipping required lake stop cannot pass verifier")
	monitor = false
	check(bad_floor == 0 and world.recovery_count == 0,"all walking routes grounded and cameras finite")
	write_report()

func write_report() -> void:
	var report := {"coverage":"two full journeys and visual UI" if render else "full scenario matrix","checks":checks,"failures":failures,"runs":runs,"floor_samples":floor_samples,"bad_floor":bad_floor,"screenshots":screenshot_names,"baseline":world.task_config.baseline,"method":"held-input and observation-only deterministic policy; real CharacterBody3D collisions; no walking teleport or clock edits; not independent human or real-LLM evidence"}
	FileAccess.open("res://tests/artifacts/phase_f_render.json" if render else "res://tests/artifacts/phase_f_qa.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("CROSS CAMPUS QA: %d checks, %d failures" % [checks,failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)
