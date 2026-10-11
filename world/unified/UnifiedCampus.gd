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

var audio: Node
var event_demo: Node
var interiors: Node
var agent_environment: Node
var mode_panel: PanelContainer
var agent_status: Label
var phone_panel: PanelContainer
var phone_words: Label
var reply_button: Button
var used_cache:=false
var landmark_index:=0
var accuracy_heatmap: Node3D
var minimap: Control
var details_button: Button
var camera_dragging := false
var explore_guide: PanelContainer
var confidence_backdrop: Panel
var exterior_polish: Node3D
const Cache:=preload("res://world/campus_seamless/SeamlessCache.gd")
const Env:=preload("res://world/campus_exterior/ExteriorEnvironment.gd")

func _ready() -> void:
	set_world_title.call_deferred()
	preload("res://systems/CampusInput.gd").configure();G.load_data()
	GameState.reset();GameState.set_flag("started",true)
	var args:=OS.get_cmdline_user_args()
	var env:=Environment.new();env.background_mode=Environment.BG_SKY
	var sky:=Sky.new();var sky_material:=ProceduralSkyMaterial.new()
	sky_material.sky_top_color=Color("739ec4");sky_material.sky_horizon_color=Color("d9e4e6")
	sky_material.ground_bottom_color=Color("65775e");sky_material.ground_horizon_color=Color("d9e4e6")
	sky.sky_material=sky_material;env.sky=sky;env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color=Color("d9e4e9");env.ambient_light_energy=.36;env.tonemap_mode=Environment.TONE_MAPPER_LINEAR
	var world_env:=WorldEnvironment.new();world_env.environment=env;add_child(world_env)
	var sun:=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-48,-30,0);sun.light_energy=.82;sun.light_color=Color("fff4e4");sun.shadow_enabled=true
	sun.directional_shadow_max_distance=200;sun.shadow_bias=.025;sun.shadow_normal_bias=1.0;add_child(sun)
	used_cache=Cache.valid() and "--v5-bake" not in args
	var source_path: String=Cache.PATH if used_cache else "res://world/campus_exterior/generated/CampusExteriorBaked.scn"
	var root: Node3D=load(source_path).instantiate()
	for child: Node in root.get_children():root.remove_child(child);child.owner=null;add_child(child)
	root.free();Env.load_data();Env.stats=get_node("CampusEnvironmentV3").get_meta("statistics")
	for group: Node in get_node("Buildings").get_children()+get_node("Landmarks").get_children():
		for node: Node in group.get_children():objects[node.name]=node
	if not used_cache:
		preload("res://world/campus_seamless/EnvelopeOpening.gd").apply(objects)
	if "--v5-bake" in args:
		set_process(false)
		if DisplayServer.get_name()=="headless":push_error("Rendered bake required");get_tree().quit(1);return
		await get_tree().process_frame
		await get_tree().process_frame
		var data: Array=JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/campus_interiors.json"))
		for d: Dictionary in data:
			var interior: Node3D=preload("res://world/campus_seamless/InteriorBuilder.gd").build(d);add_child(interior)
			await get_tree().process_frame
			Cache.own(interior,interior);var packed:=PackedScene.new();packed.pack(interior)
			ResourceSaver.save(packed,"res://world/campus_seamless/generated/"+d.interior_id+".scn",ResourceSaver.FLAG_COMPRESS)
			remove_child(interior);interior.free()
		var result:=Cache.save(self);print("V5_BAKE ",result);get_tree().quit(0 if result==OK else 1);return
	player=PlayerScene.instantiate();player.set_script(preload("res://player/CampusPlayer.gd"));player.position=G.point("upper_central")+Vector3.UP*.4;add_child(player);player.camera.far=3600
	overview=Camera3D.new();overview.projection=Camera3D.PROJECTION_ORTHOGONAL;overview.far=4500;overview.size=1420;add_child(overview);frame(Vector3(450,0,385),1420)
	ui=CanvasLayer.new();add_child(ui)
	status=Label.new();status.position=Vector2(22,18);status.add_theme_font_override("font",preload("res://systems/ChineseText.gd").FONT)
	status.add_theme_font_size_override("font_size",16);status.add_theme_color_override("font_color",Color("203c37"));ui.add_child(status)
	var labels:=Control.new();labels.set_script(preload("res://world/campus_exterior/ExteriorLabels.gd"));labels.world=self;ui.add_child(labels)
	var confidence:=Label.new();confidence.set_script(preload("res://world/campus_exterior/ExteriorConfidence.gd"));confidence.world=self
	confidence.position=Vector2(22,154);confidence.add_theme_font_override("font",preload("res://systems/ChineseText.gd").FONT);ui.add_child(confidence)
	accuracy_heatmap=preload("res://world/campus_exterior/ExteriorHeatmap.gd").build(self)
	if "--no-exterior-polish" not in args:
		exterior_polish=preload("res://world/unified/CampusExteriorPolish.gd").new();exterior_polish.world=self;add_child(exterior_polish)
	interiors=preload("res://world/campus_seamless/InteriorActivation.gd").new();interiors.world=self;add_child(interiors)
	audio=preload("res://world/campus_seamless/InteriorAudio.gd").new();audio.world=self;add_child(audio)
	event_demo=preload("res://world/unified/UnifiedEvent.gd").new();event_demo.world=self;add_child(event_demo)
	top_down="--presentation" in args;show_labels=false;update_mode()
	if "--v5-qa" in args:
		var qa:=Node.new();qa.set_script(load("res://tests/UnifiedHumanQA.gd"));qa.world=self;add_child(qa)

	agent_environment=preload("res://systems/unified/CampusAgentEnvironment.gd").new();agent_environment.world=self;add_child(agent_environment)
	if "--v5-qa" in args:
		agent_environment.human_mode=true;agent_environment.task={"id":"human_qa","goals":[]}
		WorldTime.configure(GameState.START_TIME,1,INF)
		return
	if "--v6-qa" in args:
		var qa:=Node.new();qa.set_script(load("res://tests/UnifiedCampusQA.gd"));qa.world=self;add_child(qa)
	else:
		build_modes()
		build_exploration_hud()
		if "--human" in args:select_mode(false)
		elif "--agent-demo" in args:select_mode(true)

func set_world_title() -> void:
	get_window().title="港中深微世界 · 统一校园 V6"

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
	if is_instance_valid(details_button):details_button.text="隐藏详情 [F1]" if show_labels else "名称与置信 [F1]"
	status.text="港中深微世界 · 统一校园 V6\n[F2] 俯视 / 地面　[F1] 名称与置信\nWASD 行走 · Shift 快走 · 右键拖动转镜头 · 滚轮缩放"
	if is_instance_valid(agent_environment) and agent_environment.human_mode:
		status.text="港中深微世界 · 人类探索\nWASD 行走（2.5 倍） · Shift 快走 · Tab 手机 · E 交谈\n右键拖动转镜头 · 滚轮缩放 · F1 详情 · F2 俯视 / 地面"

func toggle_details() -> void:
	show_labels = not show_labels
	if is_instance_valid(details_button): details_button.text = "隐藏详情 [F1]" if show_labels else "名称与置信 [F1]"

func _input(event: InputEvent) -> void:
	# Handle F1 before focused buttons/phone controls can consume it.
	if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_F1 or event.physical_keycode == KEY_F1):
		toggle_details()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
		camera_dragging = false
	if not is_instance_valid(agent_environment) or not agent_environment.human_mode or top_down or GameState.get_flag("modal_open") or GameState.get_flag("phone_open"):
		camera_dragging = false
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			camera_dragging = event.pressed
			get_viewport().set_input_as_handled()
		elif event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			player.zoom_camera(1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1.0)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and camera_dragging:
		player.turn_camera(event.relative)
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
		if is_instance_valid(agent_environment):agent_environment.generation+=1
		get_tree().reload_current_scene();return
	if is_instance_valid(agent_environment) and not agent_environment.human_mode and event is InputEventKey and event.keycode not in [KEY_F1,KEY_F6]:return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode if event.keycode != 0 else event.physical_keycode:
			KEY_F2:
				top_down=not top_down;show_labels=false;update_mode()
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
			KEY_6:
				interiors.present_next()
			KEY_R:
				player.position=G.point("upper_central")+Vector3.UP*.4;player.velocity=Vector3.ZERO
	if event is InputEventMouseButton and event.pressed and top_down:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: overview.size=maxf(140,overview.size*.88)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: overview.size=minf(2000,overview.size/ .88)

func _process(delta: float) -> void:
	if is_instance_valid(confidence_backdrop):confidence_backdrop.visible=show_labels
	var viewport_size:=get_viewport().get_visible_rect().size
	if is_instance_valid(mode_panel) and mode_panel.visible:mode_panel.position=(viewport_size-mode_panel.size)/2
	if is_instance_valid(agent_environment) and is_instance_valid(agent_status) and agent_environment.human_mode:
		agent_status.text="校园时间："+GameState.format_time(WorldTime.current_time,true)+"　[Esc] 返回开始菜单"
		if player.global_position.distance_to(agent_environment.registry.anchor("ling_high_table_prototype"))<3:agent_status.text+="\n高桌晚宴 · 已签到" if GameState.get_flag("high_table_signed_in") else "\n[E] 晚宴签到"
	if is_instance_valid(phone_panel):
		phone_panel.position=Vector2(maxf(18,viewport_size.x-350),180)
		phone_panel.visible=GameState.get_flag("phone_open")
		phone_words.text="消息 · 朋友\n你到哪了？高桌晚宴快开始了，我在门口等你。\n"+("已回复：我在路上，马上到。" if GameState.get_flag("responded_to_friend") else "")
		reply_button.disabled=not agent_environment.human_mode or GameState.get_flag("responded_to_friend")
	if is_instance_valid(agent_environment) and agent_environment.human_mode and Input.is_action_just_pressed("interact"):
		if player.global_position.distance_to(agent_environment.registry.anchor("ling_high_table_prototype"))<3:sign_in_high_table()
	if top_down:
		var move := Vector3(float(Input.is_key_pressed(KEY_RIGHT))-float(Input.is_key_pressed(KEY_LEFT)),0,float(Input.is_key_pressed(KEY_DOWN))-float(Input.is_key_pressed(KEY_UP)))
		overview.position+=move*overview.size*.5*delta

func build_modes() -> void:
	player.set_physics_process(false);event_demo.set_process(false)
	status.hide()
	mode_panel=PanelContainer.new();mode_panel.position=Vector2(390,220);mode_panel.custom_minimum_size=Vector2(500,300);ui.add_child(mode_panel)
	var box:=VBoxContainer.new();mode_panel.add_child(box)
	var heading:=Label.new();heading.text="港中深微世界\n统一校园 V6\n风格化校园 · 参考驱动 · 非测绘模型";heading.add_theme_font_override("font",preload("res://systems/ChineseText.gd").FONT);heading.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;box.add_child(heading)
	for item: Array in [["官方全景建造 · 东门起点",func():get_tree().change_scene_to_file("res://world/visual_campus/VisualCampus.tscn")],["人类探索",func():select_mode(false)],["智能体演示",func():select_mode(true)],["研究与复现实验",func():get_tree().change_scene_to_file("res://world/MainWorld.tscn")]]:
		var button:=Button.new();button.text=item[0];button.custom_minimum_size=Vector2(450,55);button.add_theme_font_override("font",preload("res://systems/ChineseText.gd").FONT);button.pressed.connect(item[1]);box.add_child(button)
	agent_status=Label.new();agent_status.position=Vector2(22,95);agent_status.add_theme_font_override("font",preload("res://systems/ChineseText.gd").FONT);ui.add_child(agent_status)
	phone_panel=PanelContainer.new();phone_panel.position=Vector2(880,170);phone_panel.custom_minimum_size=Vector2(330,220);ui.add_child(phone_panel)
	var phone_box:=VBoxContainer.new();phone_panel.add_child(phone_box)
	phone_words=Label.new();phone_words.custom_minimum_size=Vector2(320,135);phone_words.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;phone_words.add_theme_font_override("font",preload("res://systems/ChineseText.gd").FONT);phone_box.add_child(phone_words)
	reply_button=Button.new();reply_button.text="回复：我在路上，马上到。";reply_button.add_theme_font_override("font",preload("res://systems/ChineseText.gd").FONT);reply_button.pressed.connect(reply_phone);phone_box.add_child(reply_button);phone_panel.hide()

func build_exploration_hud() -> void:
	var hud_backdrop:=Panel.new();hud_backdrop.position=Vector2(270,18);hud_backdrop.size=Vector2(580,155);hud_backdrop.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var hud_style:=StyleBoxFlat.new();hud_style.bg_color=Color("18342fe8");hud_style.set_corner_radius_all(10);hud_backdrop.add_theme_stylebox_override("panel",hud_style);ui.add_child(hud_backdrop);ui.move_child(hud_backdrop,0)
	hud_backdrop.visible=false
	mode_panel.visibility_changed.connect(func():hud_backdrop.visible=not mode_panel.visible)
	confidence_backdrop=Panel.new();confidence_backdrop.position=Vector2(18,290);confidence_backdrop.size=Vector2(345,310);confidence_backdrop.mouse_filter=Control.MOUSE_FILTER_IGNORE;confidence_backdrop.add_theme_stylebox_override("panel",hud_style);ui.add_child(confidence_backdrop);ui.move_child(confidence_backdrop,0);confidence_backdrop.hide()
	minimap=preload("res://ui/CampusMinimap.gd").new();minimap.world=self;ui.add_child(minimap)
	status.position=Vector2(278,18);status.add_theme_font_size_override("font_size",15)
	status.add_theme_color_override("font_color",Color("edf2df"))
	agent_status.position=Vector2(278,96)
	# Reserve the left column for the minimap and readable confidence details.
	for child: Node in ui.get_children():
		if child.get_script() == preload("res://world/campus_exterior/ExteriorConfidence.gd"):
			child.position=Vector2(28,300);child.size=Vector2(325,185);child.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;child.add_theme_font_size_override("font_size",13)
	interiors.details.position=Vector2(28,490);interiors.details.add_theme_font_size_override("font_size",13)
	event_demo.prompt.position=Vector2(278,183)
	details_button=Button.new();details_button.text="名称与置信 [F1]";details_button.position=Vector2(278,132);details_button.add_theme_font_override("font",preload("res://systems/ChineseText.gd").FONT);details_button.pressed.connect(toggle_details);ui.add_child(details_button)
	details_button.hide()
	explore_guide=preload("res://ui/CampusExploreGuide.gd").new();explore_guide.world=self;ui.add_child(explore_guide)
func reply_phone() -> void:
	if GameState.get_flag("phone_open") and not GameState.get_flag("responded_to_friend"):
		GameState.set_flag("responded_to_friend",true);EventBus.emit_event("FRIEND_REPLIED")
func sign_in_high_table() -> void:
	if player.global_position.distance_to(agent_environment.registry.anchor("ling_high_table_prototype"))<3:
		GameState.set_flag("high_table_signed_in",true);EventBus.emit_event("HIGH_TABLE_SIGNED_IN")
		if is_instance_valid(agent_status):agent_status.text="高桌晚宴 · 已签到"
func select_mode(agent: bool) -> void:
	mode_panel.hide();status.show();top_down=false;update_mode();event_demo.set_process(true)
	agent_environment.human_mode=not agent
	player.human_speed_multiplier=1.0 if agent else 2.5
	player.human_camera_enabled=not agent
	player.camera.fov=60.0 if not agent else 49.0
	if is_instance_valid(details_button):details_button.show()
	if agent:run_demo()
	else:
		await agent_environment.reset({"id":"human_explore","name":"自由探索","description":"探索校园与公共室内","start":"upper_central","goals":[]})
		update_mode()
func run_demo() -> void:
	var sequence: Array=["ling_lobby","ling_common","ling_exit_main","lake_pavilion","music_foyer","music_exit_main","sports_hall_foyer","sports_hall_exit_main","library_lobby","library_reading","library_upper_platform","library_exit_main","student_centre_lobby","student_centre_exit_main","administration_lobby","administration_exit_main","teaching_a_classroom_101","teaching_a_exit_main","shaw_east_common"]
	await agent_environment.reset({"id":"showcase","name":"全校园智能体巡游","description":"沿实体道路参观校园公共空间","start":"upper_central","goals":sequence,"deadline_seconds":15000})
	status.text="港中深微世界 · 智能体演示\n同一角色身体 · 实体步行 · 不使用传送\nF1 名称与置信"
	for id: String in sequence:
		agent_status.text="正在前往："+agent_environment.registry.locations[id].display_name_zh
		var transition: Dictionary=await agent_environment.step({"type":"navigate_to","target":id})
		if not transition.valid:agent_status.text="本次导航未完成，请重新开始演示。";return
	agent_environment.finish();agent_status.text="校园巡游完成 · 所有目标均已实体到达"
