extends Node
var checks:=0
var failures: Array=[]
var world: Node3D
func _ready() -> void:run.call_deferred()
func check(value: bool,label: String) -> void:
	checks+=1
	if not value:failures.append(label);push_error("V6_SMOKE "+label)
func frames(count: int) -> void:
	for i in count:await get_tree().physics_frame
func phone_key() -> void:
	var event:=InputEventKey.new();event.keycode=KEY_TAB;event.physical_keycode=KEY_TAB;event.pressed=true
	Input.parse_input_event(event)
	for i in 3:await get_tree().process_frame
	event=InputEventKey.new();event.keycode=KEY_TAB;event.physical_keycode=KEY_TAB;event.pressed=false
	Input.parse_input_event(event)
	for i in 3:await get_tree().process_frame
func capture(name: String) -> void:
	if DisplayServer.get_name()=="headless":return
	get_tree().paused=true;await RenderingServer.frame_post_draw
	var image:=get_viewport().get_texture().get_image()
	var folder: String="res://docs/media" if "--publish-captures" in OS.get_cmdline_user_args() else "res://tests/artifacts/v6-media"
	DirAccess.make_dir_recursive_absolute(folder)
	check(image.save_jpg(folder+"/"+name+".jpg",.82)==OK,"project screenshot "+name)
	get_tree().paused=false
func run() -> void:
	if DisplayServer.get_name()!="headless":DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var entry: String=ProjectSettings.get_setting("application/run/main_scene")
	check(entry=="res://world/unified/UnifiedCampus.tscn","main product entry")
	world=load(entry).instantiate();add_child(world)
	await frames(10)
	check(world.mode_panel.visible,"normal Chinese menu")
	await capture("v6-menu")
	var buttons: Node=world.mode_panel.get_child(0)
	check(buttons.get_child(1).text=="人类探索" and buttons.get_child(2).text=="智能体演示","mode labels")
	buttons.get_child(1).pressed.emit();await frames(60)
	check(world.agent_environment.human_mode and not world.player.agent_controlled,"Human mode uses original input")
	var start: Vector3=world.player.global_position
	Input.action_press("move_right");await frames(40);Input.action_release("move_right")
	check(world.player.global_position.distance_to(start)>2,"Human physical input")
	await capture("v6-human")
	await phone_key();await frames(10)
	check(world.phone_panel.visible,"Human phone interface")
	world.reply_button.pressed.emit();await frames(3)
	check(GameState.get_flag("responded_to_friend"),"Human shared reply")
	if not failures.is_empty():print("V6_SMOKE_INPUT_STATE ",GameState.snapshot()," event_processing=",world.event_demo.is_processing());get_tree().quit(1);return
	await capture("v6-phone")
	await phone_key()
	buttons.get_child(2).pressed.emit()
	var completed:=false
	for i in 150000:
		if world.agent_environment.trajectory.size()>=12:completed=true;break
		if not world.agent_environment.failures.is_empty():break
		await get_tree().physics_frame
	check(completed,"real Agent Demo across campus and library stairs")
	check(world.player.agent_controlled,"Agent same body")
	check(world.agent_environment.visited.has("library_upper_platform"),"library interior and stairs")
	check(world.agent_environment.visited.has("ling_exit_main"),"physical exit")
	await capture("v6-agent-library")
	world.agent_environment.generation+=1;await frames(20)
	FileAccess.open("res://tests/artifacts/v6_product_smoke.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"agent_actions":world.agent_environment.trajectory.size(),"body_script":world.player.get_script().resource_path},"\t"))
	print("V6_PRODUCT_SMOKE ",checks," / ",failures.size());get_tree().quit(0 if failures.is_empty() else 1)
