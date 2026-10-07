extends Node3D
const G := preload("res://world/campus_master/CampusGeometry.gd")
const Kit := preload("res://world/MeshKit.gd")
const PlayerScene := preload("res://player/Player.tscn")
var player: CharacterBody3D
var overview: Camera3D
var top_down := true
var show_labels := false
var objects: Dictionary = {}
var ui: CanvasLayer
var status: Label

func _ready() -> void:
	DisplayServer.window_set_title("港中深：校园建筑巡游")
	set_world_title.call_deferred()
	preload("res://systems/CampusInput.gd").configure()
	G.load_data()
	GameState.reset();GameState.set_flag("started",true)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR;env.background_color = Color("c8d3ca")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("f2ead8");env.ambient_light_energy = .6
	var world_env := WorldEnvironment.new();world_env.environment=env;add_child(world_env)
	var sun := DirectionalLight3D.new();sun.rotation_degrees=Vector3(-55,-25,0);sun.light_energy=.85;add_child(sun)
	G.terrain($Terrain)
	G.lake($Regions/FairyLake)
	G.roads($Roads)
	G.bounds($Debug)
	objects=preload("res://world/campus_master/CampusMassing.gd").build($Buildings,$Landmarks)
	player=PlayerScene.instantiate();player.position=G.point("upper_central")+Vector3.UP*.4;add_child(player)
	player.camera.far=2600
	overview=Camera3D.new();overview.name="MasterplanDebugCamera";overview.projection=Camera3D.PROJECTION_ORTHOGONAL
	overview.far=4000;overview.size=1420;add_child(overview)
	frame(Vector3(450,0,385),1420)
	ui=CanvasLayer.new();add_child(ui)
	status=Label.new();status.position=Vector2(22,18);status.add_theme_font_override("font",preload("res://systems/ChineseText.gd").FONT)
	status.add_theme_font_size_override("font_size",16);status.add_theme_color_override("font_color",Color("203c37"));ui.add_child(status)
	var labels := Control.new();labels.set_script(preload("res://world/campus_master/MasterplanLabels.gd"));labels.world=self;ui.add_child(labels)
	if "--architecture-baseline" not in OS.get_cmdline_user_args():
		preload("res://world/campus_master/architecture/CampusLandscape.gd").build(self,objects)
	else:
		for r: Dictionary in G.master.regions:
			var region: Node3D=$Regions.get_node({"upper":"UpperCampus","middle":"MiddleCampus","fairy_lake":"FairyLake","lower":"LowerCampus"}[r.id])
			for i in range(8):
				var x: float=r.center[0]+cos(i*2.399)*180
				var z: float=r.center[2]+sin(i*2.399)*120
				if G.height_at(x,z)>24.5:Kit.tree(region,Vector3(x,G.height_at(x,z),z),7)
	update_mode()
	if "--architecture-capture" in OS.get_cmdline_user_args():
		var qa := Node.new();qa.set_script(load("res://tests/CampusArchitectureQA.gd"));qa.world=self;add_child(qa)
	elif "--masterplan-capture" in OS.get_cmdline_user_args() or "--masterplan-qa" in OS.get_cmdline_user_args():
		var qa := Node.new();qa.set_script(load("res://tests/CampusMasterQA.gd"));qa.world=self;add_child(qa)

func set_world_title() -> void:
	get_window().title="港中深：校园建筑巡游"

func frame(target: Vector3,size: float,oblique: bool=false) -> void:
	overview.size=size
	overview.position=target+(Vector3(0,size*.85,size*.85) if oblique else Vector3(0,1400,.01))
	overview.look_at(target,Vector3.UP if oblique else Vector3(0,0,-1))

func update_mode() -> void:
	overview.current=top_down
	player.camera.current=not top_down
	player.set_physics_process(not top_down)
	$Debug.visible=top_down
	status.text="港中深 · 校园建筑 V2\n[F2] 俯视 / 地面　[F1] 名称与置信\n[1–4] 区域　[0] 全校园　[R] 返回上园\n滚轮缩放 · 方向键平移 · WASD 行走 · Shift 快走\n空间尺寸与建筑细节为近似重建。"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode if event.keycode != 0 else event.physical_keycode:
			KEY_F2:
				top_down=not top_down;show_labels=top_down;update_mode()
			KEY_F1: show_labels=not show_labels
			KEY_0: frame(Vector3(450,0,385),1420)
			KEY_1: frame(Vector3(470,54,-90),570,true)
			KEY_2: frame(Vector3(170,30,290),620,true)
			KEY_3: frame(Vector3(0,24,55),480,true)
			KEY_4: frame(Vector3(600,8,730),750,true)
			KEY_R:
				player.position=G.point("upper_central")+Vector3.UP*.4;player.velocity=Vector3.ZERO
	if event is InputEventMouseButton and event.pressed and top_down:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: overview.size=maxf(140,overview.size*.88)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: overview.size=minf(2000,overview.size/ .88)

func _process(delta: float) -> void:
	if top_down:
		var move := Vector3(float(Input.is_key_pressed(KEY_RIGHT))-float(Input.is_key_pressed(KEY_LEFT)),0,float(Input.is_key_pressed(KEY_DOWN))-float(Input.is_key_pressed(KEY_UP)))
		overview.position+=move*overview.size*.5*delta
