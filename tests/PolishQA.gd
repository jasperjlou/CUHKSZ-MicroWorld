extends "res://tests/IntegrationQA.gd"
var routes: Array[Dictionary] = []
var route_id := ""

func run() -> void:
	reparent(get_tree().root)
	render = "--polish-render" in OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	await frames(6)
	var selected: Array = ["B", "C"] if render else ["A", "B", "C", "D", "E"]
	for id: String in selected:
		route_id = id
		if not routes.is_empty():
			await reload_world()
		check(not GameState.get_flag("started") and not world.player.photo_mode, id + " clean intro and camera")
		check(world.teacher.pending_warning == 0 and world.teacher.acknowledge_remaining == 0 and not world.teacher.closed_since_warning, id + " teacher reset")
		check(world.student.photo_remaining == 0 and not world.student.shutter_fired and not world.friend.greeted, id + " photo and friend reset")
		check(EventLogger.events.is_empty() and world.ui.toast_queue.is_empty() and not world.ui.debug_panel.visible, id + " log, speech queue and debug reset")
		var task_name := "准时赴约" if id == "A" else ("从容赴宴" if id in ["B", "D"] else "顺手帮个忙")
		await click_button(task_name)
		await click_button("开始赴宴")
		await capture("polish-" + id + "-01-start")
		if id == "B":
			await press_physical(KEY_TAB, false)
			await frames(20)
			check(world.player.model.get_node("Head").rotation.x > 0.25, "B phone has visible head posture")
			await capture("polish-B-02-phone")
			await click_button("回复")
			await press_physical(KEY_TAB)
		if id in ["C", "D"]:
			await teacher_encounter()
			if id == "D":
				await frames(550)
				await press_physical(KEY_TAB)
				await walk("move_left", 10)
				await frames(60)
				check(GameState.get_flag("teacher_warned_twice"), "D second warning follows closed phone and cooldown")
				await press_physical(KEY_TAB)
				await frames(550)
				await press_physical(KEY_TAB)
				await walk("move_right", 10)
				await frames(60)
				check(event_count("TEACHER_WARNED_PLAYER") == 1 and event_count("TEACHER_SECOND_WARNING") == 1, "D no third warning")
				await press_physical(KEY_TAB)
		if id != "A":
			await photo_encounter()
		if id == "E":
			# Actual idle time under GameClock: no assignment to time or completion flags.
			while float(GameState.get_value("current_game_time")) < GameState.DEADLINE + 1:
				await frames(120)
			check(event_count("DEADLINE_PASSED") == 1 and not GameState.get_flag("game_finished"), "E late but still playable")
		await walk_to(Vector3(0, 0, world.player.position.z))
		await walk_to(world.friend.position + Vector3(0, 0, 3))
		await frames(30)
		check(world.nearest == world.friend and world.friend.highlighted, id + " friend and prompt discoverable")
		check(world.friend.greeted, id + " friend noticed player on approach")
		await capture("polish-" + id + "-06-friend")
		await press("interact")
		check(world.ui.modal_kind == "dialogue", id + " friend dialogue opens after turning")
		await click_button("一起进入高桌晚宴")
		check(GameState.get_flag("game_finished"), id + " ending reached through actual dialogue")
		var expected := id not in ["D", "E"]
		check(bool(world.last_result.get("success", false)) == expected, id + " verifier matches route")
		check(GameState.get_flag("arrived_on_time") == (id != "E"), id + " real arrival time correct")
		check(GameState.get_flag("helped_student") == (id != "A"), id + " photo state correct")
		check(GameState.get_flag("responded_to_friend") == (id == "B"), id + " reply state correct")
		check(GameState.get_flag("teacher_warned") == (id in ["C", "D"]), id + " warning state correct")
		var story := Text.story_summary(GameState.snapshot())
		check(story.contains("两次") == (id == "D") and story.contains("一次") == (id == "C"), id + " story warning count truthful")
		check(story.contains("过了七点") == (id == "E"), id + " story lateness truthful")
		check(not world.player.photo_mode and world.player.camera.global_position.is_finite(), id + " ending camera healthy")
		await capture("polish-" + id + "-07-ending")
		ui_audit(world.ui.root)
		await press("debug_panel")
		check(world.ui.modal_kind == "replay", id + " F1 reveals event log only on demand")
		await press("debug_panel")
		check(world.ui.modal_kind == "ending", id + " F1 returns to story ending")
		routes.append({"route":id,"active_seconds":GameState.get_value("elapsed"),"arrival":GameState.format_time(GameState.get_value("arrival_time"),true),"state":GameState.snapshot(),"result":world.last_result,"story":story,"log":EventLogger.run_path})
		print("POLISH ROUTE ", id, " active_seconds=", GameState.get_value("elapsed"), " success=", world.last_result["success"])
		if render and id == "B":
			DisplayServer.window_set_size(Vector2i(960, 640))
			await capture("polish-B-08-ending-small")
			check(find_button(world.ui.root, "[R] 再玩一局").get_global_rect().end.y <= get_viewport().get_visible_rect().end.y, "small window restart button visible")
			DisplayServer.window_set_size(Vector2i(1280, 800))
	await reload_world()
	check(not GameState.get_flag("started") and world.teacher.pending_warning == 0 and world.student.photo_remaining == 0 and not world.player.photo_mode, "final restart clears temporal state")
	var report := {"checks":checks,"failures":failures,"rendered":render,"routes":routes,"screenshots":screenshot_names,"method":"held movement input, real physics, mouse and key events; no teleports or clock edits"}
	var file := FileAccess.open("res://tests/artifacts/polish-report" + ("-render" if render else "") + ".json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("POLISH COMPLETE: ", checks, " checks, ", failures.size(), " failures")
	await frames(3)
	get_tree().quit(0 if failures.is_empty() else 1)

func teacher_encounter() -> void:
	await walk_to(Vector3(0, 0, world.teacher.position.z + 12.8))
	await press_physical(KEY_TAB)
	await walk("move_forward", 40)
	check(world.teacher.pending_warning == 1 and not GameState.get_flag("teacher_warned"), route_id + " teacher visibly reacts before warning")
	check(world.teacher.attention_remaining > 0 and world.teacher.wave_remaining > 0, route_id + " teacher turn and gesture active")
	await capture("polish-" + route_id + "-02-noticed")
	await frames(60)
	check(GameState.get_flag("teacher_warned"), route_id + " delayed warning completes")
	var notice_time := -1.0
	var warning_time := -1.0
	for record: Dictionary in EventLogger.events:
		if record["event"] == "TEACHER_NOTICED_PLAYER": notice_time = record["timestamp"]
		if record["event"] == "TEACHER_WARNED_PLAYER": warning_time = record["timestamp"]
	check(warning_time - notice_time >= 0.65, route_id + " warning follows visible notice by at least 0.65 seconds")
	await capture("polish-" + route_id + "-03-warning")
	await press_physical(KEY_TAB)
	await frames(40)
	check(event_count("TEACHER_ACKNOWLEDGED") == 1, route_id + " closing phone gets delayed acknowledgement")
	await frames(210)

func photo_encounter() -> void:
	await walk_to(Vector3(0, 0, world.student.position.z + 6))
	await frames(30)
	check(GameState.get_flag("photo_request_seen"), route_id + " invitation heard from main route")
	await walk_to(world.student.position + Vector3(0, 0, 6))
	await walk_to(world.student.position + Vector3(0, 0, 2.8))
	await frames(8)
	check(world.nearest == world.student and world.student.highlighted, route_id + " photo prompt and highlight")
	await capture("polish-" + route_id + "-04-invitation")
	await press("interact")
	check(world.ui.modal_kind == "dialogue", route_id + " photo dialogue available")
	var dialogue_time: float = GameState.get_value("current_game_time")
	await frames(60)
	check(is_equal_approx(dialogue_time, GameState.get_value("current_game_time")), route_id + " dialogue pauses timer")
	await click_button("好啊")
	check(world.player.photo_mode and GameState.get_flag("busy"), route_id + " photo locks control and begins camera move")
	var position: Vector3 = world.player.position
	await walk("move_back", 25)
	check(world.player.position.distance_to(position) < 0.04, route_id + " photo prevents walking")
	await frames(40)
	check(world.player.camera.global_position.distance_to(world.player.photo_target + Vector3(0,5.2,10.5)) < 0.3, route_id + " photo camera settles on subjects")
	await capture("polish-" + route_id + "-05-camera")
	ui_audit(world.ui.root)
	if route_id == "B":
		await press("pause_game")
		var remaining: float = world.student.photo_remaining
		var camera: Transform3D = world.player.camera.global_transform
		var time: float = GameState.get_value("current_game_time")
		await frames(60)
		check(is_equal_approx(remaining, world.student.photo_remaining) and world.player.camera.global_transform.is_equal_approx(camera) and is_equal_approx(time, GameState.get_value("current_game_time")), "B pause freezes photo, camera and clock")
		await press("pause_game")
	while world.student.photo_remaining > 0:
		await frames(1)
	await frames(90)
	check(event_count("PHOTO_SHUTTER") == 1 and event_count("PHOTO_COMPLETED") == 1, route_id + " one shutter and one completion")
	check(not world.player.photo_mode and not GameState.get_flag("busy") and world.player.model.visible, route_id + " photo restores player control")
	check(world.player.camera.global_position.distance_to(world.player.global_position + Vector3(0,10.8,14)) < 0.1, route_id + " camera blends back to walking")
	check(float(GameState.get_value("current_game_time")) - dialogue_time >= 39.0, route_id + " photo animation and 35-second cost counted")
	await walk_to(Vector3(0, 0, world.student.position.z + 2.8))
