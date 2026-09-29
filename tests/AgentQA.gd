extends Node
var env: Node
var checks := 0
var failures: Array = []
var pending_response: Dictionary = {}

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures.append(message)
		push_error("INTERFACE QA: " + message)

func act(kind: String, target: String = "") -> Dictionary:
	var action := {"type":kind}
	if not target.is_empty():
		action.target = target
	var response: Dictionary = await env.step(action)
	check(response.valid and response.get("execution_error", "").is_empty(), "execute " + kind + " " + target)
	return response

func _pending_move() -> void:
	pending_response = await env.step({"type":"move_to", "target":"high_table"})

func _pending_photo() -> void:
	pending_response = await env.step({"type":"accept_photo_request"})

func run(environment: Node) -> void:
	env = environment
	var initial: Dictionary = await env.reset("careful_student", 42)
	check(JSON.parse_string(JSON.stringify(initial)) is Dictionary, "observation JSON serializable")
	check(not initial.has("teacher_warned") and not initial.has("conditions") and not initial.has("state"), "no privileged snapshot")
	check(initial.visible_entities.is_empty() and initial.messages.is_empty(), "distant NPCs and closed phone messages not visible")
	var regions = preload("res://world/WorldRegion.gd")
	check(initial.region == "upper_campus" and initial.known_regions.size() == 5, "geographical knowledge includes five regions")
	for region: Dictionary in initial.known_regions:
		if not region.enabled:
			check(not regions.TARGETS.has(region.region_id), "unbuilt region has no navigation anchor: " + region.region_id)
			check(not env.get_available_actions().any(func(a): return a.get("target") == region.region_id), "knowledge does not grant unavailable action: " + region.region_id)
	check(not regions.BUS_STOP.active and regions.CONNECTORS.filter(func(c): return c.enabled).size() == 1, "bus and future connectors remain inactive")
	for target: String in ["fairy_lake", "middle_campus", "lower_campus", "upper_shuttle_reserve"]:
		var before_closed := GameState.snapshot()
		var rejected: Dictionary = await env.step({"type":"move_to", "target":target})
		check(not rejected.valid and GameState.snapshot() == before_closed, "closed connector rejects movement without advancing: " + target)
	await env.reset("careful_student", 42)
	var task_invalid: Dictionary = await env.reset("unknown_task", 42)
	check(task_invalid.get("reason") == "unknown_task" and env.observe() == initial, "invalid task does not reset")
	var before := GameState.snapshot()
	for action in [{"type":"accept_photo_request"}, {"type":"enter_high_table"}, {"type":"reply_to_friend"}, {"type":"move_to", "target":"unknown"}, {"type":"talk_to", "target":"teacher_01"}, {"type":"wait", "seconds":9999}, {}]:
		var response: Dictionary = await env.step(action)
		check(not response.valid and GameState.snapshot() == before, "illegal action has no gameplay effects")
	check(env.invalid_actions == 7 and EventLogger.events.filter(func(e): return e.event == "AGENT_INVALID_ACTION").size() == 7, "invalid actions logged")
	await env.reset("careful_student", 42)
	check(env.invalid_actions == 0 and EventLogger.events.size() == 3, "invalid history cleared")
	# In-flight actions must reject reentrancy and be cancellable by reset.
	_pending_move()
	await get_tree().physics_frame
	var concurrent: Dictionary = await env.step({"type":"open_phone"})
	check(not concurrent.valid and concurrent.reason == "action_in_progress", "concurrent step rejected")
	await env.reset("careful_student", 42)
	await get_tree().physics_frame
	check(pending_response.get("reason") == "episode_reset", "reset cancels old action")
	check(env.world.player.navigation_direction == Vector2.ZERO and env.steps == 0, "cancelled navigation cannot affect new run")
	# Repeat identical seed and action sequence, using true scene movement.
	var fingerprints: Array = []
	for repeat in 2:
		await env.reset("careful_student", 73)
		env.world.ui.hide()
		await act("open_phone")
		check(env.observe().messages.size() == 1, "message observable with phone open")
		await act("reply_to_friend")
		await act("move_to", "main_walkway")
		await act("wait")
		check(GameState.get_flag("teacher_warned") and env.observe().personal_history.warnings_heard == 1, "real movement triggers teacher warning")
		check(GameState.get_value("elapsed") > 9 and env.world.player.position.z < 28, "real distance and phone-slowed time")
		await act("close_phone")
		await act("wait")
		await act("wait")
		await act("open_phone")
		# Starting within teacher range then moving forward still uses FOV/LOS.
		await act("move_to", "photo_spot")
		check(env.observe().region == "high_table_area", "photo event belongs to High Table region")
		check(GameState.get_flag("teacher_warned_twice"), "second warning through ordinary perception")
		await act("close_phone")
		check(env.world.player.position.distance_to(env.world.student.position) < 3.8, "photo navigation arrives within interaction range")
		await act("talk_to", "photo_student")
		check(env.get_available_actions() == [{"type":"accept_photo_request"}, {"type":"decline_photo_request"}], "dialogue gates photo choices")
		await act("accept_photo_request")
		check(GameState.get_flag("helped_student") and not GameState.get_flag("busy") and not env.world.player.photo_mode, "photo scene completes and unlocks")
		await act("move_to", "high_table")
		await act("talk_to", "friend_01")
		await act("enter_high_table")
		check(env.is_done() and not env.get_result().success, "Task C correctly fails after warnings")
		check(env.get_available_actions().is_empty(), "no actions after terminal")
		var terminal: Dictionary = await env.step({"type":"wait"})
		check(not terminal.valid and terminal.reason == "episode_finished", "terminal action rejected")
		fingerprints.append({"observation":env.observe(), "events":EventLogger.events, "result":env.get_result()})
	check(fingerprints[0] == fingerprints[1], "identical seed and actions reproduce observations events result")
	# Reset while dialogue is open and while photo busy, without patching flags.
	await env.reset("careful_student", 88)
	await act("move_to", "photo_spot")
	await act("talk_to", "photo_student")
	await env.reset("careful_student", 88)
	check(env.world.dialogue_options.is_empty() and not GameState.get_flag("modal_open"), "reset clears dialogue")
	await act("move_to", "photo_spot")
	await act("talk_to", "photo_student")
	_pending_photo()
	await get_tree().physics_frame
	check(env.world.player.photo_mode, "photo action genuinely in flight")
	await env.reset("careful_student", 88)
	await get_tree().physics_frame
	check(pending_response.get("reason") == "episode_reset" and not env.world.player.photo_mode and not GameState.get_flag("busy"), "reset cancels photo camera and pending completion")
	check(not GameState.get_flag("helped_student") and env.world.student.photo_remaining == 0, "old photo cannot complete into new run")
	await env.reset("basic", 99)
	await act("move_to", "high_table")
	await act("talk_to", "friend_01")
	await act("enter_high_table")
	for key in [KEY_F1, KEY_F1]:
		var event := InputEventKey.new()
		event.keycode = key
		event.pressed = true
		get_viewport().push_input(event)
	check(env.world.ui.modal_kind == "ending", "agent ending F1 round trip")
	var restart_key := InputEventKey.new()
	restart_key.keycode = KEY_R
	restart_key.pressed = true
	get_viewport().push_input(restart_key)
	await get_tree().process_frame
	await get_tree().process_frame
	check(not get_tree().current_scene.agent_mode and not GameState.get_flag("started"), "agent ending R restarts into human mode")
	var report := {"checks":checks, "failures":failures}
	var file := FileAccess.open("user://evaluation/interface_qa.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("INTERFACE QA ", JSON.stringify(report))
	get_tree().quit(0 if failures.is_empty() else 1)
