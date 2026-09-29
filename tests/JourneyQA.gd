extends "res://tests/IntegrationQA.gd"
const Entrance := preload("res://world/EntranceLayout.gd")
const Lake := preload("res://world/FairyLakeLayout.gd")
var monitor := false
var floor_samples := 0
var bad_floor := 0

func _physics_process(_delta: float) -> void:
	if monitor and is_instance_valid(world):
		floor_samples += 1
		var p: Vector3 = world.player.position
		var hit := world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(p+Vector3.UP*0.15,p-Vector3.UP*0.6,1))
		if hit.is_empty() or not world.player.camera.global_position.is_finite():
			bad_floor += 1

func run() -> void:
	reparent(get_tree().root)
	Engine.set_meta("journey_qa_running",true)
	render = "--journey-render" in OS.get_cmdline_user_args()
	await frames(8)
	ui_audit(world.ui.root)
	await click_button("开始漫步")
	# Sample complete paved cross-sections, especially both sides of the bend joints.
	for i in range(Entrance.POINTS.size()-1):
		for t: float in [0.01,0.5,0.99]:
			for lateral: float in [-10,-5,0,5,10]:
				var p: Vector3 = Entrance.POINTS[i].lerp(Entrance.POINTS[i+1],t)+Entrance.right_at(i).lerp(Entrance.right_at(i+1),t)*lateral
				var hit := world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(p+Vector3.UP*2,p-Vector3.UP*0.25,1))
				check(not hit.is_empty(),"paving floor at segment %d %.2f %.0f" % [i,t,lateral])
	await capture("v10-01-entry-stone")
	monitor = true
	# Held movement from the old start into the new corridor, no transport or repositioning.
	for i in range(1,Entrance.POINTS.size()):
		await walk_to(Entrance.POINTS[i])
		check(world.location_observation().zone == "ZONE_UPPER_CONNECTOR","extension reports local connector zone")
		await capture("v10-02-forecourt" if i == 2 else "v10-route-%d" % i)
	monitor = false
	check(bad_floor == 0 and world.recovery_count == 0,"old-new physical route continuously grounded")
	check(world.travelled > 35,"new route adds actual traversed space")
	var observation: Dictionary = world.environment_api.observe()
	check(observation.schema_version == "lake-4" and observation.location.semantic_path == "Entrance_TreeWalk_End","zone and semantic path in agent observation")
	check(observation.walking.estimated_time > 440,"walking ETA includes extension rather than snapping to old start")
	check(observation.destinations.has("Entrance_Forecourt"),"new paths exposed as walkable destinations")
	for id: String in world.records:
		var r: Dictionary = world.records[id]
		for key: String in ["zone","connector","walkable","obstacle","landmark","destination","semantic_tags","evidence"]:
			check(r.has(key),"semantic field "+id+"/"+key)
		check(world.builder.semantic_nodes[id].get_meta("semantic") == r,"scene/API provenance agrees "+id)
	for zone: Dictionary in observation.zones:
		if zone.id in ["ZONE_UPPER_CAMPUS","ZONE_LOWER_CAMPUS"]:
			check(not zone.active,"real campus zones remain closed")
	# Phase B opens this former cap; normal movement must cross it.
	await walk("move_back",100)
	check(world.player.position.z > 82.5 and world.player.is_on_floor() and world.recovery_count == 0,"former end cap opens into Phase B")
	await walk_to(Entrance.POINTS[-1])
	monitor = true
	var response: Dictionary = await world.environment_api.step({"type":"navigate","target":"UpperCampus_Direction"})
	check(response.ok,"same semantic navigation returns from new to old")
	for target: String in ["Entrance_Forecourt","Entrance_TreeWalk_End","UpperCampus_Direction","LowerCampus_Direction"]:
		response = await world.environment_api.step({"type":"navigate","target":target})
		check(response.ok,"continuous navigation across zones "+target)
	monitor = false
	check(bad_floor == 0 and world.recovery_count == 0,"all bidirectional routes stay on collision floor")
	response = await world.environment_api.step({"type":"inspect","target":"LowerCampus_Direction"})
	check(response.ok and world.finished,"original event task remains completable after exploration")
	await capture("v10-03-exploration-ending")
	var transitions := 0
	for row: Dictionary in world.events:
		if row.event == "ZONE_ENTERED":
			transitions += 1
	check(transitions >= 4,"zone transitions reuse existing logger")
	world.restart()
	await frames(8)
	world = get_tree().current_scene
	check(world.current_zone.is_empty() and world.elapsed == 0 and world.player.position.distance_to(Lake.POINTS[0]) < 0.5,"restart restores old start and clears zone state")
	await click_button("开始漫步")
	# A normal trip via new-area visit and back; clock and shuttle continue naturally.
	response = await world.environment_api.step({"type":"navigate","target":"Entrance_Forecourt"})
	check(response.ok,"second run visits new forecourt")
	await capture("v10-04-trees-and-terraces")
	response = await world.environment_api.step({"type":"navigate","target":"LowerCampus_Direction"})
	check(response.ok,"second run returns through lake to event")
	response = await world.environment_api.step({"type":"inspect","target":"LowerCampus_Direction"})
	check(response.ok and world.result.success,"bounded forecourt visit still permits timely event arrival")
	await capture("v10-05-timely-ending")
	var report := {"checks":checks,"failures":failures,"floor_samples":floor_samples,"bad_floor_samples":bad_floor,"screenshots":screenshot_names,"extension_game_units":extension_length(),"evidence":"Automated held movement and semantic physical navigation; not surveyed metres or independent human testing."}
	FileAccess.open("res://tests/artifacts/v10_render.json" if render else "res://tests/artifacts/v10_qa.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("JOURNEY QA: %d checks, %d failures" % [checks,failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)

func extension_length() -> float:
	var result := 0.0
	for i in range(Entrance.POINTS.size()-1):
		result += Entrance.POINTS[i].distance_to(Entrance.POINTS[i+1])
	return result
