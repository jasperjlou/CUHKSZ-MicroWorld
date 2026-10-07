extends Node
## Reuse the original bounded teacher/photo behaviors, without research API changes.
var world: Node3D
var teacher: Node3D
var student: Node3D
var companion: Node3D
var prompt: Label
var panel: PanelContainer
var words: Label
var choices: VBoxContainer
var flash: ColorRect
var photo_time_cost:=0.0
var elapsed:=0.0

func _ready() -> void:
	var ling: Node3D=world.objects.ling
	var d: Dictionary=world.interiors.definitions[0];var front: float=d.center_local[2]+d.depth/2
	teacher=preload("res://npc/TeacherNPC.gd").new();teacher.player=world.player;teacher.position=Vector3(-5,0,front+5);ling.add_child(teacher)
	student=preload("res://npc/StudentNPC.gd").new();student.player=world.player;student.clock=self;student.position=Vector3(7,0,front+5);ling.add_child(student)
	companion=Node3D.new();companion.position=Vector3(10,0,front+5);ling.add_child(companion);preload("res://world/MeshKit.gd").person(companion,Color("b7a4ca"),"gown");student.companion=companion
	prompt=Label.new();prompt.position=Vector2(22,126);prompt.add_theme_font_override("font",preload("res://systems/ChineseText.gd").FONT);world.ui.add_child(prompt)
	panel=PanelContainer.new();panel.position=Vector2(260,390);panel.custom_minimum_size=Vector2(620,0);world.ui.add_child(panel)
	var column:=VBoxContainer.new();panel.add_child(column);words=Label.new();words.custom_minimum_size=Vector2(600,0);words.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;words.add_theme_font_override("font",preload("res://systems/ChineseText.gd").FONT);column.add_child(words)
	choices=VBoxContainer.new();column.add_child(choices);panel.hide()
	flash=ColorRect.new();flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);flash.color=Color(1,1,1,0);flash.mouse_filter=Control.MOUSE_FILTER_IGNORE;world.ui.add_child(flash)
	for actor: Node3D in [teacher,student]:actor.dialogue_requested.connect(dialogue)
	student.photo_flash.connect(func():flash.color.a=.8;get_tree().create_tween().tween_property(flash,"color:a",0.0,.2);world.audio.tone(1800,.08))

func advance(seconds: float) -> void:
	photo_time_cost+=seconds

func dialogue(speaker: String,text: String,options: Array) -> void:
	GameState.set_flag("modal_open",true);panel.show();words.text=speaker+"\n"+text
	for child: Node in choices.get_children():choices.remove_child(child);child.queue_free()
	for option: Dictionary in options:
		var button:=Button.new();button.text=option.text;button.add_theme_font_override("font",preload("res://systems/ChineseText.gd").FONT);choices.add_child(button)
		button.pressed.connect(func():panel.hide();GameState.set_flag("modal_open",false);option.action.call())

func _process(delta: float) -> void:
	elapsed+=delta;GameState.set_value("elapsed",elapsed)
	var near: bool=world.player.global_position.distance_to(teacher.global_position)<40 and not world.top_down
	for actor: Node3D in [teacher,student]:actor.visible=near;actor.set_process(near);actor.set_physics_process(near)
	companion.visible=near
	var nearest: Node3D=student if world.player.global_position.distance_to(student.global_position)<world.player.global_position.distance_to(teacher.global_position) else teacher
	for actor: Node3D in [teacher,student]:actor.highlighted=near and actor==nearest and actor.nearby()
	prompt.text="[E] 与"+nearest.display_name+"交谈　[Tab] 手机" if near and nearest.nearby() else "看手机中 · 行走减速　[Tab] 收起手机" if GameState.get_flag("phone_open") else ""
	if near and Input.is_action_just_pressed("interact") and GameState.can_move():nearest.begin_interaction()
	if Input.is_action_just_pressed("phone") and GameState.can_move():
		var opened: bool=not GameState.get_flag("phone_open");GameState.set_flag("phone_open",opened);EventBus.emit_event("PHONE_OPENED" if opened else "PHONE_CLOSED")
