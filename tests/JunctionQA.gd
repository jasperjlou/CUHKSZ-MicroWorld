extends "res://tests/IntegrationQA.gd"
const J := preload("res://world/JunctionLayout.gd")
const Entrance := preload("res://world/EntranceLayout.gd")
const Connector := preload("res://world/ForestConnectorLayout.gd")
var monitor := false
var floor_samples := 0
var bad_floor := 0

func geometry_is_traceable(node: Node) -> bool:
	if node is MeshInstance3D or node is StaticBody3D:
		if not node.get_meta("confidence","") in ["verified","inferred","placeholder"] or not node.get_meta("replaceable",false) or node.get_meta("inference_basis",[]).is_empty():
			return false
	for child: Node in node.get_children():
		if not geometry_is_traceable(child):
			return false
	return true

func _physics_process(_delta: float) -> void:
	if monitor and is_instance_valid(world):
		floor_samples += 1
		var p: Vector3 = world.player.position
		var hit := world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(p+Vector3.UP*0.2,p-Vector3.UP*0.6,1))
		if hit.is_empty() or not world.player.camera.global_position.is_finite():
			bad_floor += 1

func navigate(target: String) -> void:
	var response: Dictionary = await world.environment_api.step({"type":"navigate","target":target})
	if not response.ok:
		var blockers: Array = []
		for i in world.player.get_slide_collision_count():
			blockers.append(str(world.player.get_slide_collision(i).get_collider().get_path()))
		print("NAV_DIAGNOSTIC ",target," position=",world.player.position," blockers=",blockers)
	check(response.ok,"graph physical navigation "+target)
	check(world.player.position.distance_to(Vector3(world.records[target].position[0],world.records[target].position[1],world.records[target].position[2])) < 0.5,"arrived at semantic target "+target)

func run() -> void:
	reparent(get_tree().root)
	Engine.set_meta("junction_qa_running",true)
	render = "--junction-render" in OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	await frames(8)
	await click_button("开始漫步")
	monitor = true
	for p: Vector3 in Entrance.POINTS.slice(1):
		await walk_to(p)
	for p: Vector3 in Connector.POINTS.slice(1):
		await walk_to(p)
	for id: String in ["MiddleRoad_01","MiddleRoad_02","PedestrianAccess_01","FirstJunction"]:
		await walk_to(J.point(id))
		await press_physical(KEY_C)
		await capture("phase-e-"+id)
		await press_physical(KEY_C)
	check(world.recovery_count == 0 and bad_floor == 0,"held-input lake to junction continuously grounded")
	check(geometry_is_traceable(world.builder.get_node("ReplaceableJunctionWorld")),"new visible geometry and collision carry confidence and replaceable basis")
	var state: Dictionary = world.environment_api.observe()
	check(state.ground_context.phase_e_ready and state.ground_context.new_path_enabled and state.ground_context.blocking_unknowns == 0,"D2 construction closed without blocking unknown")
	check(state.junction.selected_access_option == "B" and state.junction.branches.size() == 5,"Phase E resolves five directions")
	state.junction.nodes[0].confidence = "corrupt"
	check(world.environment_api.observe().junction.nodes[0].confidence == "inferred","new observation is a deep copy")
	for record: Dictionary in J.objects():
		check(record.confidence in ["inferred","placeholder"] and record.replaceable and not record.inference_basis.is_empty(),"traceable replaceable geometry "+record.id)
		check(world.records[record.id] == world.builder.semantic_nodes[record.id].get_meta("semantic"),"scene observation metadata agrees "+record.id)
	for segment: Dictionary in J.definition().segments:
		for i in range(segment.nodes.size()-1):
			var a := J.point(segment.nodes[i])
			var b := J.point(segment.nodes[i+1])
			var right := Vector3(b.z-a.z,0,a.x-b.x).normalized()
			for t: float in [0.001,0.1,0.5,0.9,0.999]:
				for side: float in [-3.7,0,3.7]:
					var p := a.lerp(b,t)+right*side
					var hit := world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(p+Vector3.UP*0.3,p-Vector3.UP*0.2,1))
					check(not hit.is_empty(),"full-width branch floor "+segment.id)
	var from_lower: Array[Vector3] = world.path_graph.route(J.point("LowerBranch_End"),J.point("UpperBranch_End"))
	check(J.point("CollegeBranch_Fork") in from_lower and J.point("FirstJunction") in from_lower,"branch-to-branch route uses junction rather than straight-line grass shortcut")
	for target: String in ["UpperBranch_End","OtherBranch_End","LingCollege_Approach","LowerBranch_End","FirstJunction"]:
		await navigate(target)
		var eta: float = world.transport.walking_eta()
		check(eta > 0 and is_finite(eta),"graph-aware walking ETA "+target)
		var inspected: Dictionary = await world.environment_api.step({"type":"inspect","target":target})
		check(inspected.ok and not world.finished,"branch inspection keeps original event task open "+target)
		await press_physical(KEY_C)
		await capture("phase-e-branch-"+target)
		await press_physical(KEY_C)
	var rejected: Dictionary = await world.environment_api.step({"type":"navigate","target":"Junction_VehicleRoad"})
	check(not rejected.ok,"vehicle-only ring denied to pedestrian navigation")
	await press_physical(KEY_F1)
	await frames(4)
	check(world.ui.debug.visible and world.ui.debug.text.contains("推断") and world.ui.debug.text.contains("临时占位") and world.ui.debug.text.contains("可替换"),"F1 exposes actual construction confidence in Chinese")
	if render:
		var size := get_window().size
		get_window().size = Vector2i(960,640)
		await frames(6)
		check(world.ui.debug.get_global_rect().end.y <= world.ui.root.size.y,"compact confidence panel fits screen")
		await capture("phase-e-confidence")
		get_window().size = size
	await press_physical(KEY_F1)
	await navigate("LowerCampus_Direction")
	var finish: Dictionary = await world.environment_api.step({"type":"inspect","target":"LowerCampus_Direction"})
	check(finish.ok and world.finished and world.result.arrival_status == "missed","long branch exploration still produces honest missed-event result")
	await capture("phase-e-exploration-ending")
	monitor = false
	world.restart()
	await frames(8)
	world = get_tree().current_scene
	check(world.elapsed == 0 and not world.ui.debug.visible and world.recovery_count == 0,"restart clears runtime state")
	await click_button("开始漫步")
	monitor = true
	await navigate("FirstJunction")
	await navigate("UpperCampus_Direction")
	# Return to event through the original transit system after the new-world visit.
	var response: Dictionary = await world.environment_api.step({"type":"continue_walking","reason":"原路赴约"})
	check(response.ok,"existing replanning action available after junction")
	await navigate("LowerCampus_Direction")
	response = await world.environment_api.step({"type":"inspect","target":"LowerCampus_Direction"})
	check(response.ok and world.finished,"second complete round trip resolves original verifier")
	monitor = false
	check(world.recovery_count == 0 and bad_floor == 0,"two full routes have no recovery or missing floors")
	check(world.events.any(func(e: Dictionary): return e.event == "ZONE_ENTERED") and world.events.any(func(e: Dictionary): return e.event == "NAVIGATION_FINISHED"),"existing event logging covers new geometry")
	await capture("phase-e-return-ending")
	var report := {"checks":checks,"failures":failures,"floor_samples":floor_samples,"bad_floor":bad_floor,"screenshots":screenshot_names,"method":"Held-input traversal and existing Agent locomotion with world graph; no teleport, no independent human study."}
	FileAccess.open("res://tests/artifacts/phase_e_render.json" if render else "res://tests/artifacts/phase_e_qa.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("JUNCTION QA: %d checks, %d failures" % [checks,failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)
