extends Node3D
const Campus := preload("res://world/CampusBuilder.gd")
const PlayerScene := preload("res://player/Player.tscn")
const Teacher := preload("res://npc/TeacherNPC.gd")
const Student := preload("res://npc/StudentNPC.gd")
const Friend := preload("res://npc/FriendNPC.gd")
const Clock := preload("res://systems/GameClock.gd")
const Tasks := preload("res://systems/TaskSystem.gd")
const Interface := preload("res://ui/GameUI.gd")
const Sounds := preload("res://systems/SoundCues.gd")
var player: CharacterBody3D
var teacher: Node3D
var student: Node3D
var friend: Node3D
var clock: Node
var ui: CanvasLayer
var tasks := Tasks.new()
var actors: Array[Node3D] = []
var nearest: Node3D
var last_result: Dictionary = {}
var window_title := "校园微世界：高桌晚宴"
var title_applied := false
var agent_mode := false
var agent_status := ""
var teacher_crossing_z := 0.0
var dialogue_actor := ""
var dialogue_words := ""
var dialogue_options: Array = []

func _ready() -> void:
	var polish_qa := "--polish-qa" in OS.get_cmdline_user_args() or "--polish-render" in OS.get_cmdline_user_args()
	var qa_mode := polish_qa or "--qa" in OS.get_cmdline_user_args() or "--qa-render" in OS.get_cmdline_user_args()
	window_title = "校园微世界：自动验收" if qa_mode else "校园微世界：高桌晚宴"
	DisplayServer.window_set_title(window_title)
	_configure_input()
	GameState.reset()
	EventBus.reset()
	EventLogger.prepare_next_run()
	var sounds := Node.new()
	sounds.set_script(Sounds)
	add_child(sounds)
	var campus := Node3D.new()
	campus.set_script(Campus)
	add_child(campus)
	clock = Node.new()
	clock.set_script(Clock)
	add_child(clock)
	clock.time_expired.connect(func(): finish_game("timeout"))
	player = PlayerScene.instantiate()
	player.position = Campus.to_world(Vector3(0, 0.1, 62))
	add_child(player)
	ui = CanvasLayer.new()
	ui.set_script(Interface)
	ui.world = self
	add_child(ui)
	teacher = _add_actor(Teacher, Campus.to_world(Vector3(1.7, 0, 24)))
	teacher_crossing_z = player.position.z - teacher.position.z
	student = _add_actor(Student, Campus.to_world(Campus.PHOTO_SPOT))
	student.clock = clock
	student.companion = campus.get_node("PhotoCompanion")
	student.backdrop_sign = campus.get_node("PhotoBackdropSign")
	student.photo_flash.connect(ui.flash_photo)
	friend = _add_actor(Friend, Campus.to_world(Vector3(0, 0, -64)))
	friend.finish_requested.connect(func(): finish_game("entered"))
	EventBus.event_emitted.connect(_on_event)
	EventLogger.write_failed.connect(func(): ui.toast("日志暂时无法写入，请检查存储空间与文件权限。"))
	ui.show_intro()
	if ("--agent-batch" in OS.get_cmdline_user_args() or "--agent-demo" in OS.get_cmdline_user_args() or "--agent-qa" in OS.get_cmdline_user_args()) and not Engine.has_meta("agent_runner"):
		Engine.set_meta("agent_runner", true)
		var runner := Node.new()
		runner.set_script(load("res://agents/AgentRunner.gd"))
		get_tree().root.add_child.call_deferred(runner)
	if ("--benchmark" in OS.get_cmdline_user_args() or "--benchmark-ui" in OS.get_cmdline_user_args() or "--benchmark-qa" in OS.get_cmdline_user_args()) and not Engine.has_meta("benchmark_runner"):
		Engine.set_meta("benchmark_runner", true)
		var benchmark := Node.new()
		benchmark.set_script(load("res://benchmark/BenchmarkRunner.gd"))
		get_tree().root.add_child.call_deferred(benchmark)
	if qa_mode and not Engine.has_meta("qa_active"):
		Engine.set_meta("qa_active", true)
		var qa := Node.new()
		qa.set_script(load("res://tests/PolishQA.gd" if polish_qa else "res://tests/IntegrationQA.gd"))
		qa.world = self
		add_child(qa)

func _configure_input() -> void:
	var bindings := {"move_forward":KEY_W, "move_back":KEY_S, "move_left":KEY_A, "move_right":KEY_D, "jog":KEY_SHIFT, "interact":KEY_E, "phone":KEY_TAB, "pause_game":KEY_ESCAPE, "restart":KEY_R, "debug_panel":KEY_F1}
	for action: String in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var key := InputEventKey.new()
			key.physical_keycode = bindings[action]
			InputMap.action_add_event(action, key)
			# Also accept virtual-key input from accessibility tools and remote keyboards.
			var logical_key := InputEventKey.new()
			logical_key.keycode = bindings[action]
			InputMap.action_add_event(action, logical_key)

func _add_actor(script: Script, pos: Vector3) -> Node3D:
	var actor := Node3D.new()
	actor.set_script(script)
	actor.position = pos
	actor.player = player
	actor.speech_requested.connect(ui.toast)
	actor.dialogue_requested.connect(func(speaker: String, words: String, options: Array): open_dialogue(actor.actor_id, speaker, words, options))
	add_child(actor)
	actors.append(actor)
	return actor

func start_run(task_id: String) -> void:
	GameState.set_value("current_task", task_id)
	GameState.set_flag("started", true)
	GameState.set_flag("modal_open", false)
	EventBus.reset()
	EventLogger.begin_run()
	EventBus.emit_event("GAME_STARTED", "world", {"task_id":task_id, "clock_rate":Clock.RATE, "schema_version":1})
	EventBus.emit_event("TASK_SELECTED", "world", {"task_id":task_id})
	GameState.set_flag("friend_message_received", true)
	EventBus.emit_event("FRIEND_MESSAGE_RECEIVED", "friend_01")
	ui.close_modal()

func _process(_delta: float) -> void:
	if not title_applied:
		DisplayServer.window_set_title(window_title)
		title_applied = true
	if not is_instance_valid(ui) or not GameState.get_flag("started") or GameState.get_flag("game_finished"):
		return
	nearest = null
	var distance := 3.8
	for actor in actors:
		actor.highlighted = false
		var value := actor.global_position.distance_to(player.global_position)
		if value < distance:
			distance = value
			nearest = actor
	if nearest and GameState.can_move():
		nearest.highlighted = true
	ui.set_interaction("[E] 与%s交谈" % nearest.display_name if nearest != null else "沿连廊前往高桌晚宴")
	var crossing_z: float = player.position.z - teacher.position.z
	if teacher_crossing_z * crossing_z <= 0 and absf(teacher_crossing_z - crossing_z) > 0.0001 and absf(player.position.x - teacher.position.x) < 5:
		EventBus.emit_event("TEACHER_PASSED", "player", {"phone_open":GameState.get_flag("phone_open")})
	teacher_crossing_z = crossing_z
	var pos := player.global_position
	var location := preload("res://world/WorldRegion.gd").at_position(pos)
	if GameState.get_value("current_location") != location:
		GameState.set_value("current_location", location)
		EventBus.emit_event("LOCATION_CHANGED", "player", {"location":location, "position":[pos.x, pos.y, pos.z]})

func _input(event: InputEvent) -> void:
	# Gameplay hotkeys run before Control focus navigation consumes Tab.
	# Keep normal keyboard navigation available while a modal is open.
	if event is InputEventKey and event.echo:
		return
	var viewport := get_viewport()
	if event.is_action_pressed("debug_panel"):
		ui.toggle_debug()
	elif agent_mode and not GameState.get_flag("game_finished"):
		return
	elif event.is_action_pressed("pause_game"):
		ui.handle_escape()
	elif event.is_action_pressed("restart") and GameState.get_flag("game_finished"):
		restart()
	elif GameState.can_move():
		if event.is_action_pressed("phone"):
			toggle_phone()
		elif event.is_action_pressed("interact") and nearest:
			nearest.begin_interaction()
		else:
			return
	else:
		return
	viewport.set_input_as_handled()

func toggle_phone() -> void:
	if not GameState.can_move():
		return
	var open := not GameState.get_flag("phone_open")
	GameState.set_flag("phone_open", open)
	EventBus.emit_event("PHONE_OPENED" if open else "PHONE_CLOSED")
	ui.sync_phone()

func reply_to_friend() -> void:
	if not GameState.can_move() or GameState.get_flag("responded_to_friend"):
		return
	GameState.set_flag("responded_to_friend", true)
	EventBus.emit_event("FRIEND_REPLIED")
	ui.sync_phone()
	ui.toast("你：在路上了，一会儿门口见。")

func ignore_friend() -> void:
	EventBus.emit_event("FRIEND_IGNORED")
	if GameState.get_flag("phone_open"):
		toggle_phone()

func finish_game(reason: String) -> void:
	if GameState.get_flag("game_finished"):
		return
	GameState.set_flag("game_finished", true)
	player.end_photo()
	GameState.set_flag("busy", false)
	GameState.set_flag("modal_open", false)
	EventBus.emit_event("GAME_FINISHED", "world", {"reason":reason})
	last_result = tasks.evaluate()
	EventBus.emit_event("VERIFIER_RESULT", "verifier", last_result)
	EventLogger.finish_run(last_result)
	ui.show_ending(last_result, reason)

func restart() -> void:
	if GameState.get_flag("started") and not GameState.get_flag("game_finished"):
		EventBus.emit_event("RUN_ABORTED", "world", {"reason":"restart"})
	get_tree().reload_current_scene()

func quit_game() -> void:
	if GameState.get_flag("started") and not GameState.get_flag("game_finished"):
		EventBus.emit_event("RUN_ABORTED", "world", {"reason":"quit"})
	get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()

func _on_event(record: Dictionary) -> void:
	if record["event"] == "DEADLINE_PASSED":
		ui.toast("七点了，晚宴已经开始。仍可前往；七点零四分本局结束。")

# Dialogue semantics live in the world. Both UI buttons and structured actions
# select these exact callbacks; the API never reads Control nodes.
func open_dialogue(actor_id: String, speaker: String, words: String, options: Array) -> void:
	dialogue_actor = actor_id
	dialogue_words = words
	dialogue_options = options
	GameState.set_flag("modal_open", true)
	var rendered: Array = []
	for index in options.size():
		rendered.append({"text":options[index]["text"], "action":choose_dialogue.bind(index)})
	ui.show_dialogue(speaker, words, rendered)

func choose_dialogue(index: int) -> void:
	if index < 0 or index >= dialogue_options.size():
		return
	var callback: Callable = dialogue_options[index]["action"]
	dialogue_actor = ""
	dialogue_words = ""
	dialogue_options = []
	GameState.set_flag("modal_open", false)
	ui.close_modal()
	callback.call()
