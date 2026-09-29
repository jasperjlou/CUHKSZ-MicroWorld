extends "res://tests/IntegrationQA.gd"
const Layout := preload("res://world/FairyLakeLayout.gd")
var floor_samples := 0
var bad_floor_samples := 0
var monitor_floor := false

func _physics_process(_delta: float) -> void:
	if not monitor_floor or not is_instance_valid(world) or not is_instance_valid(world.player):
		return
	floor_samples += 1
	var p: Vector3 = world.player.position
	var hit := world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(p+Vector3.UP*0.2,p-Vector3.UP*0.5,1))
	if hit.is_empty() or not world.player.camera.global_position.is_finite():
		bad_floor_samples += 1

func run() -> void:
	reparent(get_tree().root)
	Engine.set_meta("lake_qa_running",true)
	render = "--lake-render" in OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	await frames(8)
	ui_audit(world.ui.root)
	await capture("v07-01-intro")
	await click_button("开始漫步")
	check(GameState.can_move(),"lake starts through visible Chinese button")
	FileAccess.open("res://tests/artifacts/lake_semantics.json",FileAccess.WRITE).store_string(JSON.stringify(Layout.objects(),"  "))
	check(not world.ui.debug.visible,"demonstrator panel hidden by default")
	for id: String in world.records:
		var record: Dictionary = world.records[id]
		for field: String in ["type","position","interactable","walkable","obstacle","landmark","destination","semantic_tags","evidence"]:
			check(record.has(field),"semantic field %s / %s" % [id,field])
		check(world.builder.semantic_nodes[id].get_meta("semantic") == record,"scene metadata matches API: "+id)
		check(record.evidence.position != "verified","no invented surveyed coordinates: "+id)
	await capture("v07-02-entry")
	await press_physical(KEY_E,false)
	check("Prototype_Shuttle_Stop" in world.inspected,"keyboard opens entry transport choice")
	check(world.interact("UpperCampus_Direction"),"original entrance inspection remains valid")
	monitor_floor = true
	# Complete traversal using held human movement input, no teleport or navigation bypass.
	for i in range(1,Layout.POINTS.size()):
		await walk_to(Layout.POINTS[i])
		if i == 2:
			await capture("v07-03-boardwalk")
		if i == 3:
			await press_physical(KEY_E,false)
			check("FairyLake_Viewpoint_01" in world.inspected,"viewpoint interaction")
			await capture("v07-04-viewpoint")
		if i == 4:
			await capture("v07-05-pavilion")
	monitor_floor = false
	check(bad_floor_samples == 0,"continuous sloped floor and finite camera throughout traversal")
	check(world.recovery_count == 0,"no emergency recovery used")
	check(world.seen.has("Sign_01") and world.seen.has("Pavilion_01"),"stone and pavilion discovered")
	await press_physical(KEY_E,false)
	check(world.finished,"exit interaction completes slice")
	var human_run := {"elapsed_seconds":world.elapsed,"path_game_units":world.travelled,"recovery_count":world.recovery_count}
	ui_audit(world.ui.root)
	await capture("v07-06-ending")
	# Start a clean second run; runner is outside the scene and is never duplicated.
	await click_button("再走一遍")
	await frames(10)
	world = get_tree().current_scene
	check(world.seen.is_empty() and world.events.is_empty() and world.inspected.is_empty() and world.elapsed == 0 and not world.finished,"restart clears all slice state")
	await click_button("开始漫步")
	var api: RefCounted = world.environment_api
	var before: Vector3 = world.player.position
	for target: String in ["FairyLake","UpperCampus_BusStop","Road_01","missing"]:
		var invalid: Dictionary = await api.step({"type":"navigate","target":target})
		check(not invalid.ok,"reject unavailable destination: "+target)
	check(world.player.position.distance_to(before) < 0.1,"invalid actions do not move player")
	monitor_floor = true
	var result: Dictionary = await api.step({"type":"navigate","target":"FairyLake_Viewpoint_01"})
	check(result.ok,"agent follows physical path to viewpoint")
	result = await api.step({"type":"inspect","target":"FairyLake_Viewpoint_01"})
	check(result.ok,"agent inspects nearby landmark")
	result = await api.step({"type":"navigate","target":"LowerCampus_Direction"})
	check(result.ok,"agent follows physical path to exit")
	result = await api.step({"type":"navigate","target":"UpperCampus_Direction"})
	check(result.ok,"agent reverse route climbs all slopes")
	monitor_floor = false
	check(bad_floor_samples == 0,"agent traversal remains grounded")
	# Deliberate lake-side boundary pressure; actual character collision must stop it.
	await walk("move_left",100)
	check(world.player.position.y > 1.5 and world.recovery_count == 0,"lake railing prevents falling into water")
	await walk_to(Layout.POINTS[0])
	await walk("move_back",100)
	check(world.player.position.z > 45 and world.player.is_on_floor() and world.player.position.y > 2.3 and world.recovery_count == 0,"old entry now continues onto solid V10 forecourt")
	await walk_to(Layout.POINTS[0])
	await walk("move_right",150)
	check(world.player.position.x < 15 and world.recovery_count == 0,"land hedge bounds movement toward reserved road")
	await walk_to(Layout.POINTS[0])
	await press_physical(KEY_ESCAPE,false)
	var paused_time: float = world.elapsed
	await frames(40)
	check(is_equal_approx(world.elapsed,paused_time),"pause freezes activity time")
	await click_button("继续漫步")
	await press_physical(KEY_F1,false)
	ui_audit(world.ui.root)
	await capture("v07-07-debug")
	await press_physical(KEY_F1,false)
	result = await api.step({"type":"navigate","target":"LowerCampus_Direction"})
	check(result.ok,"second complete run reaches exit")
	result = await api.step({"type":"inspect","target":"LowerCampus_Direction"})
	check(result.ok and world.finished,"agent completes exit interaction")
	check(world.recovery_count == 0,"second run did not use emergency repositioning")
	if render:
		get_window().content_scale_size = Vector2i(960,640)
		DisplayServer.window_set_size(Vector2i(960,640))
		await frames(6)
	await click_button("返回高桌晚宴")
	await frames(8)
	world = get_tree().current_scene
	check(world.has_method("open_fairy_lake"),"return to original campus without CLI redirect loop")
	await capture("v07-09-campus-menu")
	await click_button("漫步神仙湖")
	await frames(8)
	world = get_tree().current_scene
	check(world.has_method("start") and not GameState.get_flag("started"),"original intro opens a fresh lake slice")
	if render:
		get_window().content_scale_size = Vector2i(960,640)
		DisplayServer.window_set_size(Vector2i(960,640))
		await frames(6)
		ui_audit(world.ui.root)
		await capture("v07-08-small-intro")
		await click_button("开始漫步")
		check(GameState.can_move(),"small window button stays visible and usable")
	var report := {"checks":checks,"failures":failures,"human_input_run":human_run,"floor_samples":floor_samples,"bad_floor_samples":bad_floor_samples,"screenshots":screenshot_names,"evidence":"Automated held-input and physical API traversal; not first-time human testing."}
	var file := FileAccess.open("res://tests/artifacts/lake_qa_render.json" if render else "res://tests/artifacts/lake_qa.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"  "))
	print("LAKE QA: %d checks, %d failures" % [checks,failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)
