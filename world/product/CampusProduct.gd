extends Node
## Both public modes share the same built world. Returning to the menu does not rebuild it.
const FONT = preload("res://systems/ChineseText.gd").FONT
var world: Node3D
var director: Node
var menu: CanvasLayer
var mode := "menu"
var human_button: Button
var agent_button: Button

func _ready() -> void:
	world = preload("res://world/visual_campus/VisualCampus.tscn").instantiate()
	add_child(world)
	world.product_host = self
	director = preload("res://world/product/CampusShowcase.gd").new()
	director.world = world
	add_child(director)
	build_menu()
	show_menu()
	var args := OS.get_cmdline_user_args()
	if "--human" in args: start_player()
	elif "--agent-demo" in args: start_showcase()

func style(color: Color, border: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(8)
	s.content_margin_left = 22
	s.content_margin_right = 22
	s.content_margin_top = 18
	s.content_margin_bottom = 18
	return s

func label(parent: Node, value: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = value
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	parent.add_child(l)
	return l

func build_menu() -> void:
	menu = CanvasLayer.new()
	menu.layer = 20
	add_child(menu)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(root)
	var shade := ColorRect.new()
	shade.color = Color(.025, .07, .065, .60)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(shade)
	var panel := PanelContainer.new()
	panel.position = Vector2(64, 140)
	panel.custom_minimum_size = Vector2(580, 420)
	panel.add_theme_stylebox_override("panel", style(Color(.035, .10, .09, .94), Color(.33, .46, .40, .7)))
	root.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	panel.add_child(box)
	label(box, "CUHKSZ  /  MICROWORLD", 15, Color("b8cdbd"))
	label(box, "港中深微型世界", 38, Color("faf7e9"))
	label(box, "从东门出发，走进校园的每一层。", 19, Color("c6d3cb"))
	var gap := Control.new()
	gap.custom_minimum_size.y = 12
	box.add_child(gap)
	human_button = entry(box, "01    玩家游玩", "自由探索 · 镜头旋转 · 小地图", start_player)
	agent_button = entry(box, "02    Agent 自动展示", "分章节漫游 · 建筑近景 · 室内与高差", start_showcase)
	label(box, "阶段版本持续精修中  ·  场景尺度按资料拟合", 13, Color("a5b7ad"))
	var footer := label(root, "下园  /  东门 — 图书馆 — 学生中心 — 知新楼 — 科研与体育馆", 14, Color("d2ddd3"))
	footer.position = Vector2(64, 740)

func entry(parent: Node, title: String, detail: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = title + "\n" + detail
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_override("font", FONT)
	b.add_theme_font_size_override("font_size", 19)
	b.add_theme_stylebox_override("normal", style(Color("183e35"), Color("365c4b")))
	b.add_theme_stylebox_override("hover", style(Color("285546"), Color("b5b77f")))
	b.add_theme_stylebox_override("pressed", style(Color("32664e")))
	b.add_theme_stylebox_override("focus", style(Color(0,0,0,0), Color("dfd69c")))
	b.pressed.connect(action)
	parent.add_child(b)
	return b

func show_menu() -> void:
	mode = "menu"
	director.stop()
	world.set_process_input(false)
	world.ui.hide()
	world.player.set_physics_process(false)
	world.player.hide()
	world.dragging = false
	world.overview.projection = Camera3D.PROJECTION_PERSPECTIVE
	world.overview.fov = 52
	world.overview.position = Vector3(-168, 96, -164)
	world.overview.look_at(Vector3(51, 8, -321))
	world.overview.current = true
	menu.show()
	human_button.grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func start_player() -> void:
	director.stop()
	mode = "player"
	menu.hide()
	GameState.reset()
	GameState.set_flag("started", true)
	world.top_down = false
	world.show_information = false
	world.information.hide()
	world.destination = {}
	world.dragging = false
	world.overview.projection = Camera3D.PROJECTION_ORTHOGONAL
	world.overview.size = world.data.get("overview_size", 540)
	var a: Array = world.data.terrain.bounds
	var centre := Vector3((a[0]+a[2])/2.0, 0, (a[1]+a[3])/2.0)
	world.overview.position = centre + Vector3.UP * 1350
	world.overview.look_at(centre, Vector3.FORWARD)
	world.player.position = Vector3(0, .3, 18)
	world.player.velocity = Vector3.ZERO
	world.player.agent_controlled = false
	world.player.human_camera_enabled = true
	world.player.show()
	world.player.model.show()
	world.player.set_physics_process(true)
	world.player.update_camera(1, true)
	world.player.camera.current = true
	world.set_process_input(true)
	world.ui.show()

func start_showcase() -> void:
	mode = "showcase"
	menu.hide()
	world.set_process_input(false)
	world.ui.hide()
	director.start()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo() and event is InputEventKey:
		if event.keycode == KEY_ESCAPE and mode != "menu":
			show_menu()
			get_viewport().set_input_as_handled()
