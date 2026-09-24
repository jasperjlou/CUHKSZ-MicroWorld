extends Node
const Verifier := preload("res://systems/TaskVerifier.gd")
const Text := preload("res://systems/ChineseText.gd")
var world: Node3D
var failures: Array[String] = []
var checks := 0
var render := false
var first_path := ""
var screenshot_names: Array[String] = []

func _ready() -> void:
	call_deferred("run")

func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures.append(description)
		push_error("QA FAIL: " + description)
	else:
		print("QA PASS: " + description)

func frames(count: int = 3) -> void:
	for _i in range(count):
		await get_tree().physics_frame
		await get_tree().process_frame

func press(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	await frames(2)
	event = InputEventAction.new()
	event.action = action
	event.pressed = false
	Input.parse_input_event(event)
	if action == "interact":
		await frames(24)

func walk(action: String, count: int = 12) -> void:
	Input.action_press(action)
	await frames(count)
	Input.action_release(action)
	await frames(2)

func press_physical(key: Key, use_physical: bool = true) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key if use_physical else 0
	event.keycode = key
	event.pressed = true
	get_viewport().push_input(event, true)
	await frames(2)
	event = InputEventKey.new()
	event.physical_keycode = key if use_physical else 0
	event.keycode = key
	event.pressed = false
	get_viewport().push_input(event, true)
	await frames(2)

func find_button(node: Node, words: String) -> Button:
	if node is Button and node.text == words and node.is_visible_in_tree():
		return node
	for child in node.get_children():
		var found := find_button(child, words)
		if found:
			return found
	return null

func click_button(words: String) -> void:
	await frames(3)
	var button := find_button(world.ui.root, words)
	check(button != null, "visible button: " + words)
	if button == null:
		return
	var position := button.get_global_rect().get_center()
	check(get_viewport().get_visible_rect().has_point(position), "button on screen: " + words)
	var motion := InputEventMouseMotion.new()
	motion.position = position
	get_viewport().push_input(motion, true)
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = position
	event.pressed = true
	get_viewport().push_input(event, true)
	await frames(1)
	event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = position
	event.pressed = false
	get_viewport().push_input(event, true)
	await frames(3)

func capture(name: String) -> void:
	if not render:
		return
	await frames(5)
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := "res://tests/artifacts/" + name + ".png"
	check(image.save_png(path) == OK, "capture " + name)
	screenshot_names.append(name)

func ui_audit(node: Node) -> void:
	if node is Label or node is Button:
		var words: String = node.text
		var untranslated := words
		for key: String in ["WASD", "Shift", "Tab", "Esc", "F1", "E", "R"]:
			untranslated = untranslated.replace("[" + key + "]", "")
		var latin := RegEx.new()
		latin.compile("[A-Za-z]")
		if latin.search(untranslated):
			check(false, "untranslated player text: " + words)
		for index in range(words.length()):
			var code := words.unicode_at(index)
			if code > 127 and not Text.FONT.has_char(code):
				check(false, "Font missing U+%04X in %s" % [code, words])
		if node is Label and node.is_visible_in_tree() and not words.is_empty():
			check(node.get_line_count() >= 1, "label shaped: " + words.left(12))
	for child in node.get_children():
		ui_audit(child)

func event_count(event_type: String) -> int:
	var count := 0
	for event in EventLogger.events:
		if event["event"] == event_type:
			count += 1
	return count

func reload_world() -> void:
	if GameState.get_flag("game_finished"):
		await press("restart")
	else:
		world.restart()
	await frames(6)
	world = get_tree().current_scene

func walk_to(target: Vector3) -> void:
	# Move via the same held input as a player, with collisions and perception active.
	var budget := 9000
	while Vector2(world.player.position.x - target.x, world.player.position.z - target.z).length() > 0.25 and budget > 0:
		for action: String in ["move_forward", "move_back", "move_left", "move_right"]:
			Input.action_release(action)
		var diff: Vector3 = target - world.player.position
		if absf(diff.x) > 0.16:
			Input.action_press("move_right" if diff.x > 0 else "move_left")
		if absf(diff.z) > 0.16:
			Input.action_press("move_back" if diff.z > 0 else "move_forward")
		await frames(1)
		budget -= 1
	for action: String in ["move_forward", "move_back", "move_left", "move_right"]:
		Input.action_release(action)
	check(budget > 0, "walkable route waypoint " + str(target))
	await frames()

func run() -> void:
	reparent(get_tree().root)
	render = "--qa-render" in OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	await frames(6)
	check(world != null and world.player != null, "world and player instantiated")
	check(world.tasks.presets.size() == 3, "three structured tasks loaded")
	await capture("01-intro")
	ui_audit(world.ui.root)
	# Exhaustively evaluate the documented boolean task predicates, independent of the UI.
	for mask in range(16):
		var state := {"reached_high_table":bool(mask & 1), "helped_student":bool(mask & 2), "arrived_on_time":bool(mask & 4), "teacher_warned":bool(mask & 8), "arrival_time":GameState.START_TIME if mask & 1 else -1.0}
		var basic := Verifier.verify(world.tasks.get_task("basic"), state)
		var helpful := Verifier.verify(world.tasks.get_task("helpful_student"), state)
		var careful := Verifier.verify(world.tasks.get_task("careful_student"), state)
		check(basic["success"] == bool(mask & 1), "basic predicate " + str(mask))
		check(helpful["success"] == (bool(mask & 1) and bool(mask & 2) and bool(mask & 4)), "helpful predicate " + str(mask))
		check(careful["success"] == (bool(mask & 1) and bool(mask & 2) and bool(mask & 4) and not bool(mask & 8)), "careful predicate " + str(mask))
	check(not Verifier.verify(world.tasks.get_task("basic"), {})["success"], "missing state fails closed")
	check(not Verifier.verify(world.tasks.get_task("helpful_student"), {"helped_student":true, "arrived_on_time":true, "reached_high_table":true, "arrival_time":GameState.DEADLINE + 1})["success"], "inconsistent late arrival cannot claim on-time success")
	await click_button("开始赴宴")
	check(GameState.get_flag("started"), "start button works with real mouse input")
	if not GameState.get_flag("started"):
		print("QA ABORT: start button input failed")
		get_tree().quit(1)
		return
	first_path = EventLogger.run_path
	await frames()
	var start: Vector3 = world.player.position
	await walk("move_forward", 30)
	var normal_distance: float = start.z - world.player.position.z
	check(normal_distance > 0.25, "WASD moves player")
	start = world.player.position
	Input.action_press("jog")
	await walk("move_forward", 30)
	Input.action_release("jog")
	var jog_distance: float = start.z - world.player.position.z
	check(jog_distance > normal_distance * 1.4, "Shift runs faster than walking")
	await press_physical(KEY_TAB)
	check(GameState.get_flag("phone_open"), "physical Tab opens phone before GUI focus navigation")
	var reply_button := find_button(world.ui.root, "回复")
	if reply_button:
		reply_button.focus_mode = Control.FOCUS_ALL
		reply_button.grab_focus()
	await press_physical(KEY_TAB)
	check(not GameState.get_flag("phone_open"), "physical Tab closes phone with a focused UI button")
	await press_physical(KEY_TAB, false)
	check(GameState.get_flag("phone_open"), "logical Tab supports virtual-key input")
	start = world.player.position
	await walk("move_forward", 30)
	var slow_distance: float = start.z - world.player.position.z
	check(slow_distance < normal_distance * 0.85, "phone reduces movement speed")
	start = world.player.position
	Input.action_press("jog")
	await walk("move_forward", 30)
	Input.action_release("jog")
	check(absf((start.z - world.player.position.z) - slow_distance) < 0.08, "Shift cannot bypass phone slowdown")
	check(not GameState.get_flag("teacher_warned"), "no warning outside range")
	await click_button("回复")
	world.reply_to_friend()
	check(GameState.get_flag("responded_to_friend") and event_count("FRIEND_REPLIED") == 1, "reply is idempotent")
	await capture("02-phone")
	ui_audit(world.ui.root)
	world.player.position = world.teacher.position + Vector3(0, 0.05, -4)
	await walk("move_right", 10)
	check(not GameState.get_flag("teacher_warned"), "teacher cannot see behind")
	world.player.position = world.teacher.position + Vector3(0, 0.05, 6)
	await frames()
	check(not GameState.get_flag("teacher_warned"), "stationary phone user is not warned")
	# Solid occluder physically blocks the teacher's ray.
	var wall := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(8, 4, 0.5)
	collider.shape = shape
	wall.add_child(collider)
	world.add_child(wall)
	wall.position = world.teacher.position + Vector3(0, 1.5, 3)
	await frames()
	check(not world.teacher.can_see_player(), "raycast occlusion")
	await walk("move_right", 10)
	check(not GameState.get_flag("teacher_warned"), "no warning through wall")
	wall.queue_free()
	await frames()
	await walk("move_forward", 60)
	check(GameState.get_flag("teacher_warned"), "visible moving phone user warned")
	await walk("move_right", 12)
	check(event_count("TEACHER_WARNED_PLAYER") == 1 and not GameState.get_flag("teacher_warned_twice"), "first warning only once; holding phone is not second offense")
	await press("phone")
	await frames(32)
	check(event_count("TEACHER_ACKNOWLEDGED") == 1, "nearby phone close acknowledged")
	GameState.set_value("elapsed", float(GameState.get_value("elapsed")) + 9.0)
	await press("phone")
	await walk("move_left", 60)
	check(GameState.get_flag("teacher_warned_twice"), "second offense after close and cooldown")
	await walk("move_right", 12)
	check(event_count("TEACHER_SECOND_WARNING") == 1, "second warning capped")
	await press("phone")
	await press("debug_panel")
	world.player.update_camera(1.0, true)
	await capture("03-teacher-debug")
	ui_audit(world.ui.root)
	await press("debug_panel")
	world.player.position = world.student.position + Vector3(0, 0.05, 2.5)
	world.player.update_camera(1.0, true)
	await frames(32)
	check(GameState.get_flag("photo_request_seen"), "photo invitation triggered by proximity")
	await press("interact")
	check(world.ui.modal_kind == "dialogue", "E opens photo dialogue")
	await capture("04-photo-dialogue")
	ui_audit(world.ui.root)
	world.ui.close_modal()
	world.student.decline_photo()
	check(GameState.get_flag("declined_photo") and not GameState.get_flag("helped_student"), "decline has no completion")
	var before: float = GameState.get_value("current_game_time")
	world.student.accept_photo()
	world.student.accept_photo()
	check(event_count("PHOTO_ACCEPTED") == 1, "photo start cannot double execute")
	check(GameState.get_flag("busy"), "photo freezes player")
	await frames(215)
	check(GameState.get_flag("helped_student") and not GameState.get_flag("busy"), "photo completes without deadlock")
	check(float(GameState.get_value("current_game_time")) - before >= 35, "photo time cost applied")
	await capture("05-photo-completed")
	# Pause freezes clock and movement, then resumes.
	await press("pause_game")
	before = GameState.get_value("current_game_time")
	start = world.player.position
	await walk("move_forward", 12)
	check(is_equal_approx(before, GameState.get_value("current_game_time")) and world.player.position.distance_to(start) < 0.05, "pause freezes clock and movement")
	await capture("06-pause")
	await press("pause_game")
	check(not GameState.get_flag("paused"), "Esc resumes")
	world.player.position = world.friend.position + Vector3(0, 0.05, 2.5)
	world.player.update_camera(1.0, true)
	await frames()
	await capture("07-hall")
	await press("interact")
	check(GameState.get_flag("reached_high_table") and GameState.get_flag("arrived_on_time"), "friend records arrival")
	check(world.friend.feedback().contains("拍照") and world.friend.feedback().contains("提醒"), "friend feedback reads real actions")
	await capture("08-friend")
	world.ui.close_modal()
	world.finish_game("entered")
	world.finish_game("entered")
	check(world.last_result["success"], "helpful task successful end-to-end")
	check(event_count("GAME_FINISHED") == 1 and event_count("VERIFIER_RESULT") == 1, "ending and verifier single-shot")
	await capture("09-ending")
	ui_audit(world.ui.root)
	var stored: Variant = JSON.parse_string(FileAccess.get_file_as_string(first_path))
	check(stored is Array and stored.size() == EventLogger.events.size(), "event log valid JSON and complete")
	check(not EventLogger.io_error, "atomic log writes succeeded")
	var summary: Variant = JSON.parse_string(FileAccess.get_file_as_string(EventLogger.summary_path))
	check(summary is Dictionary and summary["result"]["success"], "summary persisted")
	var sequence := 0
	for record: Dictionary in stored:
		sequence += 1
		check(record["sequence"] == sequence and record.has("timestamp") and record.has("game_time") and record.has("actor") and record.has("data"), "event schema and ordering " + str(sequence))
	world.ui.show_replay()
	await capture("10-event-viewer")
	ui_audit(world.ui.root)
	# Reload real scene, not just flags: tests private NPC state and timer reset.
	await reload_world()
	for key: String in ["phone_open","responded_to_friend","teacher_warned","teacher_warned_twice","helped_student","declined_photo","photo_request_seen","game_finished","reached_high_table"]:
		check(not GameState.get_flag(key), "restart resets " + key)
	check(world.teacher.closed_since_warning == false and world.student.photo_remaining == 0.0, "restart resets NPC internals")
	check(EventLogger.events.is_empty() and EventLogger.run_path.is_empty(), "restart clears current log before the next run starts")
	check(GameState.get_value("arrival_time") == -1 and GameState.get_value("current_game_time") == GameState.START_TIME, "restart resets time")
	world.start_run("careful_student")
	check(EventLogger.run_path != first_path and event_count("PHOTO_COMPLETED") == 0, "new log isolated")
	check(JSON.parse_string(FileAccess.get_file_as_string(first_path)).size() == stored.size(), "previous log unchanged")
	# Boundary: exactly 19:00 is late, per 'before 19:00'.
	GameState.set_value("current_game_time", GameState.DEADLINE)
	world.friend.interact()
	check(not GameState.get_flag("arrived_on_time"), "exact deadline counts as late")
	world.ui.close_modal()
	world.finish_game("entered")
	check(not world.last_result["success"], "late and missing photo fail")
	await capture("11-failure")
	ui_audit(world.ui.root)
	if render:
		DisplayServer.window_set_size(Vector2i(960, 640))
		await capture("12-ending-960")
		DisplayServer.window_set_size(Vector2i(1920, 1080))
		await capture("13-ending-1920")
		DisplayServer.window_set_size(Vector2i(1280, 800))
	await reload_world()
	world.start_run("careful_student")
	world.player.position = world.student.position + Vector3(0, 0.05, 2.5)
	world.student.accept_photo()
	await frames(215)
	world.player.position = world.friend.position + Vector3(0, 0.05, 2.5)
	await frames()
	await press("interact")
	world.ui.close_modal()
	world.finish_game("entered")
	check(world.last_result["success"], "careful task can succeed without warnings")
	await reload_world()
	world.start_run("basic")
	GameState.set_value("current_game_time", GameState.END_TIME - 0.01)
	await frames(5)
	check(GameState.get_flag("game_finished") and not world.last_result["success"], "timeout finishes without arrival")
	check(event_count("VERIFIER_RESULT") == 1, "timeout verified and logged")
	# Exercise the complete route with rendering too, rather than just staged screenshots.
	await reload_world()
	world.start_run("careful_student")
	await capture("14-route-start")
	await press("phone")
	await click_button("回复")
	await press("phone")
	await walk_to(Vector3(0, 0, world.student.position.z + 6))
	await walk_to(world.student.position + Vector3(0, 0, 6))
	await walk_to(world.student.position + Vector3(0, 0, 2.5))
	await press("interact")
	check(world.ui.modal_kind == "dialogue", "real route reaches photo interaction")
	await click_button("好啊")
	await frames(215)
	await capture("15-route-photo")
	await walk_to(Vector3(0, 0, world.student.position.z + 2.5))
	await walk_to(world.friend.position + Vector3(0, 0, 2.5))
	await press("interact")
	world.ui.close_modal()
	world.finish_game("entered")
	check(world.last_result["success"], "full route succeeds without teleporting or editing time")
	check(float(GameState.get_value("elapsed")) < 60, "brisk full route finishes within one minute of active time")
	check(GameState.get_flag("responded_to_friend"), "full route includes replying to friend")
	await capture("16-route-ending")
	print("QA ROUTE active_seconds=", GameState.get_value("elapsed"), " arrival=", GameState.format_time(GameState.get_value("arrival_time"), true))
	var report := {"checks":checks,"failures":failures,"rendered":render,"screenshots":screenshot_names,"engine":Engine.get_version_info(),"log_directory":ProjectSettings.globalize_path(EventLogger.log_directory)}
	var report_file := FileAccess.open("res://tests/artifacts/qa-report" + ("-render" if render else "") + ".json", FileAccess.WRITE)
	report_file.store_string(JSON.stringify(report, "\t"))
	report_file.close()
	print("QA COMPLETE: %s checks, %s failures" % [checks, failures.size()])
	# Release the final scene's active audio playback before shutting down the engine.
	await reload_world()
	await frames(6)
	get_tree().quit(0 if failures.is_empty() else 1)
