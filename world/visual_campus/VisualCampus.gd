extends Node3D
const Builder := preload("res://world/visual_campus/VisualCampusBuilder.gd")
const FONT := preload("res://systems/ChineseText.gd").FONT
var data: Dictionary
var builder: RefCounted
var player: CharacterBody3D
var overview: Camera3D
var ui: CanvasLayer
var minimap: Control
var information: PanelContainer
var location_text: Label
var destination: Dictionary={}
var show_information:=false
var top_down:=false
var dragging:=false
var built_ms:=0
var product_host: Node

func _ready() -> void:
	set_world_title.call_deferred()
	preload("res://systems/CampusInput.gd").configure()
	GameState.reset();GameState.set_flag("started",true)
	data=JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/campus_visual_build.json"))
	lighting();var begin:=Time.get_ticks_msec();builder=Builder.new();builder.build(self,data);built_ms=Time.get_ticks_msec()-begin
	preload("res://world/visual_campus/CampusRenderBatches.gd").build(self)
	player=preload("res://player/Player.tscn").instantiate();player.set_script(preload("res://player/CampusPlayer.gd"));player.scale=Vector3.ONE*.66;player.position=Vector3(0,.3,18);add_child(player)
	player.human_speed_multiplier=2.5;player.human_camera_enabled=true;player.camera_offset=Vector3(0,2.5,5.2);player.camera.fov=55;player.camera.near=.08;player.camera.far=1600;player.update_camera(1,true)
	overview=Camera3D.new();overview.projection=Camera3D.PROJECTION_ORTHOGONAL;overview.size=data.get("overview_size",540);overview.near=.5;overview.far=3000;add_child(overview)
	var bounds: Array=data.terrain.bounds;var centre:=Vector3((bounds[0]+bounds[2])/2.0,0,(bounds[1]+bounds[3])/2.0)
	overview.position=centre+Vector3.UP*1350;overview.look_at(centre,Vector3.FORWARD);overview.current=false
	hud()

func set_world_title() -> void:
	DisplayServer.window_set_title("港中深微型世界 · 官方全景建造 · 东门起点")

func lighting() -> void:
	var environment:=WorldEnvironment.new();var e:=Environment.new();e.background_mode=Environment.BG_SKY
	var sky:=Sky.new();var sky_material:=ProceduralSkyMaterial.new();sky_material.sky_top_color=Color("6d91b0");sky_material.sky_horizon_color=Color("c9d5d5");sky_material.ground_horizon_color=Color("c9d5d5");sky_material.ground_bottom_color=Color("77856b");sky.sky_material=sky_material;e.sky=sky
	e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;e.ambient_light_color=Color("d0d7d9");e.ambient_light_energy=.38;e.tonemap_mode=Environment.TONE_MAPPER_FILMIC
	environment.environment=e;add_child(environment)
	var sun:=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-48,-35,0);sun.light_color=Color("fff6e8");sun.light_energy=.50;sun.shadow_enabled=true;sun.directional_shadow_max_distance=230;add_child(sun)

func text(parent: Node,value: String,p: Vector2,font_size: int=16) -> Label:
	var label:=Label.new();label.text=value;label.position=p;label.add_theme_font_override("font",FONT);label.add_theme_font_size_override("font_size",font_size);label.add_theme_color_override("font_color",Color("edf0e5"));parent.add_child(label);return label

func hud() -> void:
	ui=CanvasLayer.new();add_child(ui)
	minimap=preload("res://world/visual_campus/VisualCampusMap.gd").new();minimap.world=self;ui.add_child(minimap)
	var header:=Panel.new();header.position=Vector2(276,18);header.size=Vector2(490,66);header.mouse_filter=Control.MOUSE_FILTER_IGNORE;header.add_theme_stylebox_override("panel",minimap.panel_style());ui.add_child(header)
	text(header,"右键转向 · V 切换视角 · F1 操作与依据",Vector2(14,9),17)
	text(header,"WASD 行走 / Shift 跑步 / 滚轮缩放 / Esc 菜单",Vector2(14,37),14)
	location_text=text(ui,"",Vector2(276,96),15)
	information=PanelContainer.new();information.position=Vector2(276,140);information.add_theme_stylebox_override("panel",minimap.panel_style());ui.add_child(information)
	var label:=text(information,"V 第一 / 第三人称；右键拖动转向；滚轮调第三人称距离\nF2 俯视；R 回东门并重置视角；小地图点击设目标\n起点：官方 East Gate 门槛中心 (0,0,0)\n面向校园：右 +X，入校 -Z，上 +Y\n地图朝上表示入校方向；地理北向尚未校准\n形体参照官方全景；尺度和未完整可见层数为估计\n大学图书馆与知新楼黄宜弘梁凤仪图书馆分别标注",Vector2.ZERO,16)
	label.add_theme_constant_override("outline_size",0);information.hide()

func _process(_delta: float) -> void:
	if not is_instance_valid(player):return
	var near_name:="东门外道路";var nearest:=INF
	for record: Dictionary in data.landmarks:
		var distance:=player.position.distance_to(builder.point(record.position))
		if distance<nearest:nearest=distance;near_name=record.name
	location_text.text=("第一人称" if player.first_person else "第三人称")+" · "+near_name
	if not destination.is_empty():
		var distance:=Vector2(player.position.x,player.position.z).distance_to(Vector2(destination.position[0],destination.position[2]))
		location_text.text+="  ·  "+destination.name+(" 已到达" if distance<5 else " 直线 "+str(roundi(distance))+" m")
	if show_information:location_text.text+="  ·  局部坐标 "+str(player.position.snapped(Vector3.ONE*.1))

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode if event.keycode!=0 else event.physical_keycode:
			KEY_V:
				if not top_down:player.toggle_view()
				get_viewport().set_input_as_handled()
			KEY_F1:show_information=not show_information;information.visible=show_information;get_viewport().set_input_as_handled()
			KEY_F2:
				dragging=false;top_down=not top_down;overview.current=top_down;player.camera.current=not top_down;player.set_physics_process(not top_down);get_viewport().set_input_as_handled()
			KEY_R:
				dragging=false;player.first_person=false;player.orbit_yaw=0;player.orbit_pitch=0;player.orbit_zoom=1
				player.position=Vector3(0,.3,18);player.velocity=Vector3.ZERO;player.update_camera(1,true)
			KEY_ESCAPE:
				if is_instance_valid(product_host):product_host.show_menu()
				else:get_tree().change_scene_to_file.call_deferred("res://world/product/CampusProduct.tscn")
				get_viewport().set_input_as_handled()
	if event is InputEventMouseButton:
		if event.button_index==MOUSE_BUTTON_RIGHT:dragging=event.pressed
		if event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
			var direction:=1.0 if event.button_index==MOUSE_BUTTON_WHEEL_UP else -1.0
			if top_down:overview.size=clampf(overview.size*pow(.9,direction),160,1600)
			else:player.zoom_camera(direction)
	if event is InputEventMouseMotion and dragging and not top_down:player.turn_camera(event.relative)
