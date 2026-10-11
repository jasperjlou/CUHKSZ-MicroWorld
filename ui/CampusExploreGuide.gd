extends PanelContainer
## Optional human-only exploration goals; completion follows the actual body.
const FONT := preload("res://systems/ChineseText.gd").FONT
const TOUR: Array[String] = ["ling_lobby", "lake_pavilion", "library_reading", "teaching_a_classroom_101"]
var world: Node3D
var target_id := ""
var tour_active := false
var tour_index := 0
var visited: Array[String] = []
var notice := "点击小地图上的建筑设置目的地"
var notice_seconds := 0.0
var heading: Label
var destination: Label
var context: Label
var tour_button: Button
var clear_button: Button

func _ready() -> void:
	custom_minimum_size = Vector2(310, 0)
	var style := StyleBoxFlat.new(); style.bg_color = Color("18342ff0")
	style.set_corner_radius_all(10); style.set_content_margin_all(14)
	add_theme_stylebox_override("panel", style)
	var column := VBoxContainer.new(); column.add_theme_constant_override("separation", 8); add_child(column)
	heading = label("自由探索", 18); column.add_child(heading)
	destination = label(notice, 15); column.add_child(destination)
	context = label("", 13); column.add_child(context)
	var buttons := HBoxContainer.new(); column.add_child(buttons)
	tour_button = Button.new(); tour_button.text = "开始校园漫游"; tour_button.add_theme_font_override("font", FONT); tour_button.pressed.connect(toggle_tour); buttons.add_child(tour_button)
	clear_button = Button.new(); clear_button.text = "清除标记"; clear_button.add_theme_font_override("font", FONT); clear_button.pressed.connect(clear_target); buttons.add_child(clear_button)

func label(text: String, font_size: int) -> Label:
	var result := Label.new(); result.text = text; result.custom_minimum_size.x = 282
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.add_theme_font_override("font", FONT); result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", Color("edf2df")); return result

func set_destination(id: String) -> void:
	if not world.agent_environment.registry.locations.has(id): return
	tour_active = false; target_id = id; notice_seconds = 0
	tour_button.text = "开始校园漫游"

func clear_target() -> void:
	tour_active = false; target_id = ""; notice = "点击小地图上的建筑设置目的地"; notice_seconds = 0
	tour_button.text = "开始校园漫游"

func toggle_tour() -> void:
	if tour_active:
		tour_active = false; target_id = ""; notice = "漫游已暂停，可继续自由探索"
		tour_button.text = "继续校园漫游"; return
	if tour_index >= TOUR.size(): tour_index = 0; visited.clear()
	tour_active = true; target_id = TOUR[tour_index]; notice_seconds = 0
	tour_button.text = "暂停漫游"

func _process(delta: float) -> void:
	visible = world.agent_environment.human_mode and not world.mode_panel.visible and not GameState.get_flag("phone_open") and not GameState.get_flag("modal_open")
	if not visible: return
	var view := get_viewport_rect().size
	position = Vector2(maxf(18, view.x - size.x - 18), maxf(18, view.y - size.y - 18))
	update_progress(delta)

func update_progress(delta: float) -> void:
	var registry = world.agent_environment.registry
	var distance := INF
	if not target_id.is_empty():
		distance = world.player.global_position.distance_to(registry.anchor(target_id))
		if distance < 3.0:
			var reached := target_id
			notice = "已到达：" + registry.locations[reached].display_name_zh
			notice_seconds = 4.0
			if tour_active:
				visited.append(reached); tour_index += 1
				if tour_index < TOUR.size(): target_id = TOUR[tour_index]
				else:
					tour_active = false; target_id = ""; notice = "校园漫游完成！已探索 4 个地点"; notice_seconds = 8
					tour_button.text = "再次漫游"
			else: target_id = ""
	notice_seconds = maxf(0, notice_seconds - delta)
	heading.text = "校园漫游 · %s / 4" % tour_index if tour_active or tour_index == TOUR.size() else "自由探索"
	if not target_id.is_empty():
		distance = world.player.global_position.distance_to(registry.anchor(target_id))
		destination.text = registry.locations[target_id].display_name_zh + "\n直线距离：%d 游戏单位 · 沿道路前往" % int(distance)
		if notice_seconds > 0: destination.text = notice + "\n" + destination.text
	else: destination.text = notice
	clear_button.disabled = target_id.is_empty()
	var inside: String = world.interiors.active_id
	if not inside.is_empty():
		context.text = "室内：" + registry.locations[inside].display_name_zh + "\n沿楼梯可探索公共楼层，自动门靠近开启"
	elif not world.event_demo.prompt.text.is_empty(): context.text = world.event_demo.prompt.text
	else: context.text = "右键转镜头 · 滚轮缩放\nTab 手机 · F1 详情 · Esc 返回菜单"
