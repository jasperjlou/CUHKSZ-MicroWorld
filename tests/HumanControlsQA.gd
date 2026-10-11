extends SceneTree
## Actual input events and physical motion, including UI focus and camera modes.
var world: Node3D
var checks := 0
var failures: Array[String] = []
var rendered := false

func _initialize() -> void:
	rendered = DisplayServer.get_name() != "headless"
	if rendered: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	run.call_deferred()

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error("HUMAN CONTROLS QA: " + label)

func frames(count: int) -> void:
	for i in count: await physics_frame

func key(code: int, physical: bool = false, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.pressed = true; event.echo = echo
	if physical: event.physical_keycode = code
	else: event.keycode = code
	Input.parse_input_event(event)
	await frames(2)
	event.pressed = false; event.echo = false
	Input.parse_input_event(event)

func mouse(button: int, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button; event.pressed = pressed; event.position = Vector2(700, 400)
	Input.parse_input_event(event)
	await frames(2)

func capture(name: String) -> void:
	if not rendered: return
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png("res://tests/artifacts/" + name + ".png") == OK, "render capture " + name)

func walk_to(id: String) -> bool:
	# Feed human WASD input along public test waypoints, retaining all collisions.
	world.player.orbit_yaw = 0; world.player.orbit_pitch = 0; world.player.orbit_zoom = 1
	var points = world.agent_environment.registry.plan(world.player.global_position, id)
	var reached := true
	for point: Vector3 in points:
		var arrived := false
		for tick in 3000:
			var direction: Vector3 = point - world.player.global_position; direction.y = 0
			if direction.length() < 0.4: arrived = true; break
			direction = direction.normalized()
			for action: String in ["move_left", "move_right", "move_forward", "move_back"]: Input.action_release(action)
			Input.action_press("move_right" if direction.x >= 0 else "move_left", absf(direction.x))
			Input.action_press("move_back" if direction.z >= 0 else "move_forward", absf(direction.z))
			await physics_frame
		if not arrived: reached = false; break
	for action: String in ["move_left", "move_right", "move_forward", "move_back"]: Input.action_release(action)
	await frames(10)
	return reached and world.player.global_position.distance_to(world.agent_environment.registry.anchor(id)) < 1.5

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	world = load("res://world/unified/UnifiedCampus.tscn").instantiate()
	root.add_child(world)
	await frames(5)
	await world.select_mode(false)
	await frames(10)
	check(world.player.human_speed_multiplier == 2.5, "human movement opt-in 2.5x")
	check(world.player.human_camera_enabled, "human camera enabled")
	check(world.minimap.visible, "minimap visible in human mode")
	check(world.minimap.position.x < 30 and world.minimap.position.y < 30, "minimap upper left")
	world.details_button.grab_focus()
	await key(KEY_F1)
	check(world.show_labels, "F1 works with focused GUI button")
	await key(KEY_F1, false, true)
	check(world.show_labels, "F1 auto-repeat does not toggle")
	await key(KEY_F1, true)
	check(not world.show_labels, "physical F1 closes details")
	world.details_button.emit_signal("pressed")
	check(world.show_labels, "clickable details fallback")
	world.details_button.emit_signal("pressed")
	await capture("human-controls-default")
	var before_camera: Vector3 = world.player.camera.global_position
	await mouse(MOUSE_BUTTON_RIGHT, true)
	var motion := InputEventMouseMotion.new(); motion.relative = Vector2(150, -35)
	Input.parse_input_event(motion)
	await frames(40)
	check(absf(world.player.orbit_yaw) > 0.8, "right drag turns camera yaw")
	check(absf(world.player.orbit_pitch) > 0.1, "right drag turns camera pitch")
	check(world.player.camera.global_position.distance_to(before_camera) > 3, "camera physically orbits body")
	var forward: Vector3 = -world.player.camera.global_basis.z; forward.y = 0; forward = forward.normalized()
	Input.action_press("move_forward"); await frames(25)
	var moving_direction: Vector3 = world.player.velocity; moving_direction.y = 0
	check(moving_direction.normalized().dot(forward) > 0.95, "W follows rotated camera rather than world axis")
	Input.action_release("move_forward"); await frames(15)
	await mouse(MOUSE_BUTTON_RIGHT, false)
	var yaw: float = world.player.orbit_yaw
	Input.parse_input_event(motion); await frames(2)
	check(world.player.orbit_yaw == yaw, "mouse release stops orbit")
	await mouse(MOUSE_BUTTON_WHEEL_UP, true)
	check(world.player.orbit_zoom < 1.0, "wheel zoom")
	# Face world +X along the known upper campus road, then measure body motion.
	world.player.orbit_yaw = 0; world.player.orbit_pitch = 0; world.player.orbit_zoom = 1
	await frames(5)
	var before: Vector3 = world.player.global_position
	var before_map: Vector2 = world.minimap.map_point(before)
	Input.action_press("move_right")
	await frames(60)
	var walk_velocity := Vector2(world.player.velocity.x, world.player.velocity.z).length()
	check(absf(walk_velocity - 12.75) < 0.3, "actual walk speed 12.75")
	check(world.player.global_position.distance_to(before) > 9, "physical walking distance increases")
	check(world.minimap.map_point(world.player.global_position).distance_to(before_map) > 1, "minimap marker follows physical motion")
	Input.action_press("jog"); await frames(35)
	check(absf(Vector2(world.player.velocity.x, world.player.velocity.z).length() - 20.75) < 0.3, "Shift jog speed 20.75")
	Input.action_release("jog"); Input.action_release("move_right"); await frames(20)
	await capture("human-controls-explore")
	await key(KEY_F1)
	await capture("human-controls-f1")
	await key(KEY_F2)
	check(world.top_down and not world.player.is_physics_processing(), "F2 overview stops human body input")
	yaw = world.player.orbit_yaw
	await mouse(MOUSE_BUTTON_RIGHT, true); Input.parse_input_event(motion); await frames(2)
	check(world.player.orbit_yaw == yaw, "overview excludes human orbit")
	await mouse(MOUSE_BUTTON_RIGHT, false)
	await key(KEY_F2)
	check(not world.top_down and world.player.is_physics_processing(), "F2 returns to human view")
	# Actual GUI map click selects a building without moving the body.
	var before_pick: Vector3 = world.player.global_position
	var click := InputEventMouseButton.new(); click.button_index = MOUSE_BUTTON_LEFT; click.pressed = true
	var local_click: Vector2 = world.minimap.map_point(world.objects.library.global_position)
	if rendered:
		click.position = world.minimap.global_position + local_click
		Input.parse_input_event(click)
	else:
		# Headless has no rendered GUI hit-test surface; exercise the local handler.
		click.position = local_click; world.minimap._gui_input(click)
	await frames(2)
	click.pressed = false; Input.parse_input_event(click); await frames(2)
	check(world.explore_guide.target_id == "library", "map click selects actual public building")
	check(world.player.global_position.distance_to(before_pick) < 0.1, "map click never teleports body")
	world.explore_guide.clear_target()
	world.explore_guide.tour_button.emit_signal("pressed")
	check(world.explore_guide.tour_active and world.explore_guide.target_id == "ling_lobby", "optional tour starts with real lobby")
	world.explore_guide.tour_button.emit_signal("pressed")
	check(not world.explore_guide.tour_active, "tour can pause for free exploration")
	world.explore_guide.tour_button.emit_signal("pressed")
	check(world.explore_guide.tour_index == 0 and world.explore_guide.tour_active, "tour resumes without losing progress")
	await world.agent_environment.reset({"id":"tour_start_fixture","start":"ling_lobby","goals":[]})
	await frames(10)
	check(world.explore_guide.tour_index == 1 and world.explore_guide.target_id == "lake_pavilion", "physical lobby arrival advances tour once")
	await frames(10)
	check(world.explore_guide.tour_index == 1, "arrival progress does not duplicate every frame")
	# Freeze the tour updater during resets: arrivals are checked after setup settles.
	world.explore_guide.set_process(false)
	for id: String in ["lake_pavilion", "library_reading", "teaching_a_classroom_101"]:
		await world.agent_environment.reset({"id":"tour_arrival_fixture","start":id,"goals":[]})
		world.explore_guide.update_progress(0.0)
	check(world.explore_guide.tour_index == 4 and not world.explore_guide.tour_active, "all physical tour destinations complete")
	check(world.explore_guide.visited.size() == 4, "four distinct exploration stops recorded")
	world.explore_guide.set_process(true)
	await frames(3)
	await capture("human-controls-tour-complete")
	world.explore_guide.clear_target()
	root.size = Vector2i(960, 640); await frames(10)
	var view_size: Vector2 = root.get_visible_rect().size
	check(world.explore_guide.position.x >= 0 and world.explore_guide.position.y >= 0 and world.explore_guide.position.x + world.explore_guide.size.x <= view_size.x, "guide stays inside 960px window")
	await key(KEY_TAB); await frames(5)
	check(world.phone_panel.visible and world.phone_panel.position.x + world.phone_panel.size.x <= view_size.x, "phone fits smaller window")
	check(not world.explore_guide.visible, "phone does not compete with exploration card")
	await capture("human-controls-small-phone")
	await key(KEY_TAB); await frames(5)
	root.size = Vector2i(1280, 800); await frames(10)
	# Indoor camera adaptation still runs underneath the human orbit.
	await world.agent_environment.reset({"id":"indoor_controls_qa","start":"library_lobby","goals":[]})
	await frames(40)
	check(world.interiors.active_id == "library", "real library interior active")
	before_camera = world.player.camera.global_position
	await mouse(MOUSE_BUTTON_RIGHT, true); Input.parse_input_event(motion); await frames(40)
	await mouse(MOUSE_BUTTON_RIGHT, false)
	check(world.player.camera.global_position.distance_to(before_camera) > 0.3, "orbit survives interior camera adaptation")
	await capture("human-controls-interior")
	check(await walk_to("library_reading"), "2.5x human physically walks through library")
	check(await walk_to("library_upper_platform"), "2.5x human climbs actual library stairs")
	check(await walk_to("library_exit_main"), "2.5x human descends stairs and exits library")
	# Same inherited movement, original speed when controlled by an Agent.
	world.player.agent_controlled = true; world.player.navigation_direction = Vector2(1, 0)
	world.player.human_speed_multiplier = 2.5
	world.player.global_position = Vector3(375, 49.5, 55); world.player.velocity = Vector3.ZERO
	await frames(60)
	check(absf(Vector2(world.player.velocity.x, world.player.velocity.z).length() - 5.1) < 0.3, "Agent keeps original speed even with human multiplier")
	world.player.navigation_direction = Vector2.ZERO
	var report := {"checks":checks,"failures":failures,"rendered":rendered,"manual_human_testing":false}
	var report_path := "res://tests/artifacts/human_controls_qa.json" if rendered else "res://tests/artifacts/human_controls_headless_qa.json"
	FileAccess.open(report_path, FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("HUMAN_CONTROLS_QA ", JSON.stringify(report))
	quit(0 if failures.is_empty() else 1)
