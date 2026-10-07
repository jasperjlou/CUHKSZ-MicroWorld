extends Node3D
const G := preload("res://world/campus_exterior/ExteriorGeometry.gd")
const Kit := preload("res://world/MeshKit.gd")
const PlayerScene := preload("res://player/Player.tscn")
var player: CharacterBody3D
var overview: Camera3D
var top_down := true
var show_labels := false
var objects: Dictionary = {}
var ui: CanvasLayer
var status: Label

var used_cache:=false
var landmark_index:=0
var accuracy_heatmap: Node3D
const Cache:=preload("res://world/campus_exterior/ExteriorCache.gd")
const Env:=preload("res://world/campus_exterior/ExteriorEnvironment.gd")

func _ready() -> void:
	set_world_title.call_deferred()
	preload("res://systems/CampusInput.gd").configure();G.load_data()
	GameState.reset();GameState.set_flag("started",true)
	var args:=OS.get_cmdline_user_args()
	var env:=Environment.new();env.background_mode=Environment.BG_SKY
	var sky:=Sky.new();var sky_material:=ProceduralSkyMaterial.new()
	sky_material.sky_top_color=Color("819fae");sky_material.sky_horizon_color=Color("d3dad2")
	sky_material.ground_bottom_color=Color("65775e");sky_material.ground_horizon_color=Color("d3dad2")
	sky.sky_material=sky_material;env.sky=sky;env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color=Color("d9e2df");env.ambient_light_energy=.35;env.tonemap_mode=Environment.TONE_MAPPER_LINEAR
	var world_env:=WorldEnvironment.new();world_env.environment=env;add_child(world_env)
	var sun:=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-48,-30,0);sun.light_energy=.75;sun.light_color=Color("fff1dc");sun.shadow_enabled=false
	sun.directional_shadow_max_distance=160;add_child(sun)
	used_cache=Cache.valid() and "--v4-authoring" not in args
	if used_cache:
		var root: Node3D=load(Cache.PATH).instantiate()
		for child: Node in root.get_children():root.remove_child(child);child.owner=null;add_child(child)
		root.free();Env.load_data();Env.stats=get_node("CampusEnvironmentV3").get_meta("statistics")
		for group: Node in get_node("Buildings").get_children()+get_node("Landmarks").get_children():
			for node: Node in group.get_children():objects[node.name]=node
	else:
		for name: String in ["Terrain","Roads","Regions","Buildings","Landmarks","Debug"]:
			var node:=Node3D.new();node.name=name;add_child(node)
		for name: String in ["UpperCampus","MiddleCampus","FairyLake","LowerCampus"]:
			var node:=Node3D.new();node.name=name;$Regions.add_child(node)
		G.terrain($Terrain);G.lake($Regions/FairyLake)
		objects=preload("res://world/campus_exterior/ExteriorMassing.gd").build($Buildings,$Landmarks)
		Env.build(self);preload("res://world/campus_exterior/ExteriorContext.gd").build(self)
	if "--v4-bake" in args:
		set_process(false)
		if DisplayServer.get_name()=="headless":
			push_error("Bake requires a rendering server to serialize MultiMesh transforms.");get_tree().quit(1);return
		await get_tree().process_frame
		await get_tree().process_frame
		# Persist sampled terrain for exact cheap runtime collision/ground agreement.
		var grid: Dictionary={}
		for z in range(int(G.master.terrain.z_min),int(G.master.terrain.z_max)+1,5):
			for x in range(int(G.master.terrain.x_min),int(G.master.terrain.x_max)+1,5):grid[str(x)+","+str(z)]=G.raw_height(x,z)
		FileAccess.open("res://systems/data/campus_terrain_grid_v4.json",FileAccess.WRITE).store_string(JSON.stringify(grid))
		var result:=Cache.save(self);print("V4_BAKE ",result);set_process(false);get_tree().quit(0 if result==OK else 1);return
	player=PlayerScene.instantiate();player.position=G.point("upper_central")+Vector3.UP*.4;add_child(player);player.camera.far=3600
	overview=Camera3D.new();overview.projection=Camera3D.PROJECTION_ORTHOGONAL;overview.far=4500;overview.size=1420;add_child(overview);frame(Vector3(450,0,385),1420)
	ui=CanvasLayer.new();add_child(ui)
	status=Label.new();status.position=Vector2(22,18);status.add_theme_font_override("font",preload("res://systems/ChineseText.gd").FONT)
	status.add_theme_font_size_override("font_size",16);status.add_theme_color_override("font_color",Color("203c37"));ui.add_child(status)
	var labels:=Control.new();labels.set_script(preload("res://world/campus_exterior/ExteriorLabels.gd"));labels.world=self;ui.add_child(labels)
	var confidence:=Label.new();confidence.set_script(preload("res://world/campus_exterior/ExteriorConfidence.gd"));confidence.world=self
	confidence.position=Vector2(22,154);confidence.add_theme_font_override("font",preload("res://systems/ChineseText.gd").FONT);ui.add_child(confidence)
	accuracy_heatmap=preload("res://world/campus_exterior/ExteriorHeatmap.gd").build(self)
	top_down="--presentation" in args or "--v4-capture" in args;show_labels=false;update_mode()
	if "--v4-capture" in args:
		var qa:=Node.new();qa.set_script(load("res://tests/CampusExteriorQA.gd"));qa.world=self;add_child(qa)

func set_world_title() -> void:
	get_window().title="港中深：校园外观巡游 V4"

func frame(target: Vector3,size: float,oblique: bool=false) -> void:
	overview.projection=Camera3D.PROJECTION_ORTHOGONAL
	overview.size=size
	overview.position=target+(Vector3(0,size*.85,size*.85) if oblique else Vector3(0,1400,.01))
	overview.look_at(target,Vector3.UP if oblique else Vector3(0,0,-1))

func update_mode() -> void:
	overview.current=top_down
	player.camera.current=not top_down
	player.set_physics_process(not top_down)
	if has_node("Debug"):$Debug.visible=show_labels
	status.text="港中深 · 校园外观 V4\n[F2] 俯视 / 地面　[F1] 名称与置信\n[1–4] 区域　[5] 地标巡览　[0] 全校园　[R] 返回上园\n滚轮缩放 · 方向键平移 · WASD 行走 · Shift 快走"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode if event.keycode != 0 else event.physical_keycode:
			KEY_F2:
				top_down=not top_down;show_labels=false;update_mode()
			KEY_F1: show_labels=not show_labels
			KEY_F6: accuracy_heatmap.visible=not accuracy_heatmap.visible
			KEY_0: frame(Vector3(450,0,385),1420)
			KEY_1: frame(Vector3(470,54,-90),570,true)
			KEY_2: frame(Vector3(170,30,290),620,true)
			KEY_3: frame(Vector3(0,24,55),480,true)
			KEY_4: frame(Vector3(600,8,730),750,true)
			KEY_5:
				var ids: Array[String]=["ling","music","lake_pavilion","library","student_centre","administration","shaw_east"]
				var root: Node3D=objects[ids[landmark_index%ids.size()]];landmark_index+=1
				top_down=true;update_mode();overview.projection=Camera3D.PROJECTION_PERSPECTIVE
				overview.position=root.position+Vector3(35,18,75);overview.look_at(root.position+Vector3.UP*9)
			KEY_R:
				player.position=G.point("upper_central")+Vector3.UP*.4;player.velocity=Vector3.ZERO
	if event is InputEventMouseButton and event.pressed and top_down:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: overview.size=maxf(140,overview.size*.88)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: overview.size=minf(2000,overview.size/ .88)

func _process(delta: float) -> void:
	if top_down:
		var move := Vector3(float(Input.is_key_pressed(KEY_RIGHT))-float(Input.is_key_pressed(KEY_LEFT)),0,float(Input.is_key_pressed(KEY_DOWN))-float(Input.is_key_pressed(KEY_UP)))
		overview.position+=move*overview.size*.5*delta
