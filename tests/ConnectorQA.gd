extends "res://tests/IntegrationQA.gd"
const Layout := preload("res://world/ForestConnectorLayout.gd")
const Entrance := preload("res://world/EntranceLayout.gd")
var monitoring := false
var samples := 0
var errors := 0

func _physics_process(_delta: float) -> void:
	if monitoring and is_instance_valid(world):
		samples += 1
		var p: Vector3 = world.player.position
		var hit := world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(p+Vector3.UP*0.18,p-Vector3.UP*0.6,1))
		if hit.is_empty() or not world.player.camera.global_position.is_finite():
			errors += 1

func run() -> void:
	reparent(get_tree().root)
	Engine.set_meta("connector_qa_running",true)
	render = "--connector-render" in OS.get_cmdline_user_args()
	await frames(8)
	await click_button("开始漫步")
	monitoring = true
	for i in range(1,Entrance.POINTS.size()):
		await walk_to(Entrance.POINTS[i])
	await capture("v10d2-01-join")
	for i in range(1,Layout.POINTS.size()):
		await walk_to(Layout.POINTS[i])
		check(world.location_observation().zone == Layout.ZONE,"new region honestly reports unknown connector")
		await capture("v10d2-0%d-route" % (i+1))
	monitoring = false
	check(errors == 0 and world.recovery_count == 0,"held-input old-A-B route grounded")
	# Cross-width collision checks catch cracks missed by a centerline walk.
	for i in range(Layout.POINTS.size()-1):
		for t: float in [0.001,0.1,0.5,0.9,0.999]:
			for lateral: float in [-0.95,-0.5,0,0.5,0.95]:
				var p: Vector3 = Layout.POINTS[i].lerp(Layout.POINTS[i+1],t)+Layout.right_at(i).lerp(Layout.right_at(i+1),t)*lerpf(Layout.WIDTHS[i],Layout.WIDTHS[i+1],t)*lateral
				var hit := world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(p+Vector3.UP*0.5,p-Vector3.UP*0.2,1))
				check(not hit.is_empty(),"full-width collision %d %.3f %.2f" % [i,t,lateral])
	var observation: Dictionary = world.environment_api.observe()
	var frozen: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://references/regions/fairy_lake/frontier_connector_b.json"))
	check(Layout.POINTS[-1] == Vector3(frozen.game_position[0],frozen.game_position[1],frozen.game_position[2]),"frozen frontier unchanged")
	for i in Layout.POINTS.size():
		var p: Array = frozen.route_points[i]
		check(Layout.POINTS[i] == Vector3(p[0],p[1],p[2]) and Layout.WIDTHS[i] == frozen.widths[i],"Phase B route baseline preserved")
	check(observation.frontier.confidence == "inferred" and observation.frontier.extension_enabled,"inferred construction is enabled without claiming surveyed registration")
	check(observation.location.frontier_id == "FRONTIER_CONNECTOR_B","frontier ID available at endpoint")
	check(world.records.UNKNOWN_CONNECTOR.confidence == "inferred","old endpoint alias retained with inferred connection")
	check(world.records.Connector_Tower_View.evidence.identity == "unknown","anonymous tower stays anonymous")
	check(not world.ui.debug.visible,"survey hidden by default")
	var ground: Dictionary = observation.ground_context
	check(ground.authored_section == "AUTHORED_B" and ground.registration == "unknown","authored section never certifies geographic registration")
	check(ground.reference_segments.size() == 4 and ground.coverage.reference_pedestrian_continuity.unknown == 2,"per-segment unknown gaps retained")
	check(ground.new_path_enabled and not ground.candidate_mapping_is_localization,"construction may open path without turning candidates into surveyed locations")
	check(ground.gap_review.size() == 2 and ground.phase_e_ready and ground.blocking_unknowns == 0,"historical evidence remains while construction enables Phase E")
	for gap: Dictionary in ground.gap_review:
		check(not gap.closed and gap.status == "unknown" and gap.matched_chain_links == 0,"missing ground remains unresolved "+gap.id)
		check(gap.evidence_count == gap.reviewed_references.size() and gap.source_family_count == 1,"review count is not independent-source count "+gap.id)
		check(not world.records.has(gap.id),"research gap is not navigable "+gap.id)
	ground.gap_review[0].closed = true
	check(not world.environment_api.observe().ground_context.gap_review[0].closed,"mutating a gap observation cannot close evidence gate")
	for segment: Dictionary in ground.reference_segments:
		check(segment.game_position == null and not segment.game_instantiated and not segment.new_walkable,"reference segment has no invented location "+segment.id)
		check(not world.records.has(segment.id),"reference-only segment not navigable "+segment.id)
	ground.reference_segments[0].confidence = "corrupted_observation"
	check(world.environment_api.observe().ground_context.reference_segments[0].confidence == "verified","observation mutation cannot change evidence")
	check(not JSON.stringify(world.environment_api.observe().ground_context).contains("correct_route"),"ground observation has no route-answer field")
	check(observation.location.semantic_path == "UNKNOWN_CONNECTOR" and not observation.location.global_connection_verified,"unknown endpoint does not certify geography")
	for record: Dictionary in Layout.objects():
		check(world.records[record.id] == world.builder.semantic_nodes[record.id].get_meta("semantic"),"scene/API metadata agrees "+record.id)
		for key: String in ["zone","connector","walkable","obstacle","landmark","confidence","evidence"]:
			check(record.has(key),"semantic field "+record.id+"/"+key)
	for id: String in ["Connector_Road_View","Connector_Tower_View","Connector_Green_Slope"]:
		var denied: Dictionary = await world.environment_api.step({"type":"navigate","target":id})
		check(not denied.ok,"scenery not navigable "+id)
	await walk("move_back",150)
	check(world.player.position.z > 114 and world.recovery_count == 0 and world.player.is_on_floor(),"former boundary opens into inferred middle road")
	await walk_to(Layout.POINTS[-1])
	monitoring = true
	for target: String in ["Roadside_Path_01","Entrance_Forecourt","UNKNOWN_CONNECTOR","UpperCampus_Direction","LowerCampus_Direction"]:
		var response: Dictionary = await world.environment_api.step({"type":"navigate","target":target})
		check(response.ok,"continuous semantic route "+target)
	monitoring = false
	check(errors == 0 and world.recovery_count == 0,"both-direction physical navigation stays grounded")
	var response: Dictionary = await world.environment_api.step({"type":"inspect","target":"LowerCampus_Direction"})
	check(response.ok and world.finished,"original task still resolves after extended exploration")
	await capture("v10d2-05-exploration-ending")
	world.restart()
	await frames(8)
	world = get_tree().current_scene
	check(world.elapsed == 0 and world.current_zone.is_empty(),"restart clears time and zone")
	check(not world.ui.debug.visible and world.player.camera_offset == Vector3(0,9.4,16.5),"restart clears survey and view")
	check(world.environment_api.observe().ground_context.authored_section != "AUTHORED_B","reset clears current authored segment")
	await click_button("开始漫步")
	response = await world.environment_api.step({"type":"navigate","target":"UNKNOWN_CONNECTOR"})
	check(response.ok,"second run navigates across old-A-B")
	await capture("v10d2-06-road-view")
	# Use the real player control, not a screenshot-only camera change.
	await press_physical(KEY_C,false)
	check(world.player.camera_offset.z < 0,"native-compatible C binding turns towards landmarks")
	await frames(60)
	await capture("v10d2-07-outward-landmarks")
	await press_physical(KEY_F1,false)
	await frames(3)
	check(world.ui.debug.visible and world.ui.debug.text.contains("真实位置未经测绘配准"),"F1 exposes Chinese evidence with unknown retained")
	check(world.ui.debug.text.contains("连接甲：推断") and world.ui.debug.text.contains("接入乙：临时占位") and world.ui.debug.text.contains("可替换"),"F1 explains both specific gaps and evidence-count caveat")
	await capture("v10d2-10-frontier-survey")
	for side in range(2):
		await press_physical(KEY_V,side == 1)
		await frames(30)
		check(absf(world.player.camera_offset.x) == 12 and world.player.camera_offset.z == 0,"side view uses actual player control")
		await capture("v10d2-11-side-%d" % side)
		var origin: Vector3 = world.player.position
		var towards: float = -signf(world.player.camera_offset.x)
		await walk("move_forward",8)
		check((world.player.position.x-origin.x)*towards > 0.1,"side-view input moves screen-forward")
		await walk("move_back",8)
		var nav: Dictionary = await world.environment_api.step({"type":"navigate","target":"UNKNOWN_CONNECTOR"})
		check(nav.ok and world.player.position.distance_to(Layout.POINTS[-1]) < 0.4,"semantic navigation ignores camera orientation")
	await press_physical(KEY_C,false)
	check(world.player.camera_offset.z < 0,"C restores forward view after side survey")
	if render:
		var window_size := get_window().size
		get_window().size = Vector2i(960,640)
		await frames(5)
		check(world.ui.debug.get_global_rect().end.y <= world.ui.root.size.y,"compact survey stays within canvas height")
		await capture("v10d2-09-compact-ui")
		get_window().size = window_size
	await press_physical(KEY_F1)
	var before: Vector3 = world.player.position
	await walk("move_back",10)
	check(world.player.position.z < before.z,"movement remains screen-relative in reverse view")
	await press_physical(KEY_C)
	check(world.player.camera_offset.z > 0,"C restores lake-facing view")
	response = await world.environment_api.step({"type":"navigate","target":"LowerCampus_Direction"})
	check(response.ok,"second run returns all the way to event")
	response = await world.environment_api.step({"type":"inspect","target":"LowerCampus_Direction"})
	check(response.ok and world.finished,"second complete trip resolves verifier")
	await capture("v10d2-08-ending")
	var report := {"checks":checks,"failures":failures,"floor_camera_samples":samples,"sample_errors":errors,"screenshots":screenshot_names,"method":"Native engine rendering, scripted held input and same-capsule semantic navigation. Not independent human testing."}
	FileAccess.open("res://tests/artifacts/v10d2_render.json" if render else "res://tests/artifacts/v10d2_qa.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("CONNECTOR QA: %d checks, %d failures" % [checks,failures.size()])
	if "--keep-frontier-open" in OS.get_cmdline_user_args() and failures.is_empty():
		world.restart()
		await frames(8)
		world = get_tree().current_scene
		await click_button("开始漫步")
		await world.environment_api.step({"type":"navigate","target":"UNKNOWN_CONNECTOR"})
		print("FRONTIER REVIEW READY: arrived using normal physical navigation")
		return
	get_tree().quit(0 if failures.is_empty() else 1)

