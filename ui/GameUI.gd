extends CanvasLayer
const Text := preload("res://systems/ChineseText.gd")
const INK := Color("243d39")
const PAPER := Color("f5efdf")
const GOLD := Color("c69347")
var world: Node3D
var root: Control
var objective: Label
var time_label: Label
var location_label: Label
var phone_status: Label
var interaction: Label
var toast_panel: PanelContainer
var toast_label: Label
var toast_remaining := 0.0
var phone_panel: PanelContainer
var phone_body: VBoxContainer
var debug_panel: PanelContainer
var debug_label: Label
var modal_layer: Control
var modal_body: VBoxContainer
var modal_footer: VBoxContainer
var modal_kind := ""
var flash_layer: ColorRect
var selected_task := "helpful_student"
var task_description: Label
var refresh_elapsed := 0.0
var controls_hint: Label
var photo_overlay: Control
var photo_caption: Label
var toast_queue: Array[String] = []

func _ready() -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var theme := Theme.new()
	theme.default_font = Text.FONT
	theme.default_font_size = 21
	theme.set_color("font_color", "Label", INK)
	theme.set_color("font_color", "Button", PAPER)
	theme.set_color("font_hover_color", "Button", Color.WHITE)
	theme.set_color("font_pressed_color", "Button", Color.WHITE)
	theme.set_color("font_disabled_color", "Button", Color("ced1c9"))
	theme.set_stylebox("normal", "Button", _style(INK, 9, 12))
	theme.set_stylebox("hover", "Button", _style(Color("41635b"), 9, 12))
	theme.set_stylebox("pressed", "Button", _style(Color("547568"), 9, 12))
	theme.set_stylebox("disabled", "Button", _style(Color("84958a"), 9, 12))
	var focus := _style(Color(0, 0, 0, 0), 9, 2)
	focus.border_color = GOLD
	focus.set_border_width_all(3)
	theme.set_stylebox("focus", "Button", focus)
	root.theme = theme
	build_hud()
	build_phone()
	build_debug()
	build_photo_overlay()
	modal_layer = Control.new()
	modal_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(modal_layer)
	modal_layer.hide()
	flash_layer = ColorRect.new()
	flash_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash_layer.color = Color(1, 1, 1, 0)
	flash_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(flash_layer)

func _style(color: Color, radius: int = 14, padding: int = 20) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding
	return style

func _panel(parent: Node, width: float = 0) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(PAPER))
	panel.custom_minimum_size.x = width
	parent.add_child(panel)
	return panel

func _column(parent: Node, gap: int = 12) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", gap)
	parent.add_child(column)
	return column

func _label(parent: Node, words: String, size: int = 21, color: Color = INK) -> Label:
	var label := Label.new()
	label.text = words
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(label)
	return label

func _button(parent: Node, words: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = words
	button.custom_minimum_size.y = 46
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Keyboard movement and E/Tab remain owned by the game, not a focused phone button.
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(func():
		if world.agent_mode and not GameState.get_flag("game_finished"):
			return
		get_tree().call_group("sound_cues", "click")
		action.call()
	)
	parent.add_child(button)
	return button

func build_hud() -> void:
	var objective_panel := _panel(root)
	objective_panel.position = Vector2(20, 20)
	objective_panel.size = Vector2(345, 102)
	objective_panel.add_theme_stylebox_override("panel", _style(Color(0.96, 0.94, 0.87, 0.93), 12, 16))
	var column := _column(objective_panel, 5)
	_label(column, "今晚 · 高桌晚宴", 16, Color("6d7d6c"))
	objective = _label(column, "前往晚宴门口", 21)
	phone_status = _label(column, "正在看手机 · 移动变慢", 16, Color("98684d"))
	phone_status.hide()
	var clock_panel := _panel(root)
	clock_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	clock_panel.offset_left = -221
	clock_panel.offset_right = -20
	clock_panel.offset_top = 20
	clock_panel.offset_bottom = 130
	var clock_column := _column(clock_panel, 2)
	time_label = _label(clock_column, "18:55", 34)
	_label(clock_column, "19:00 开宴", 16)
	location_label = _label(clock_column, "入口广场", 15, Color("687263"))
	var bottom := _panel(root)
	bottom.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	bottom.offset_left = -300
	bottom.offset_right = 300
	bottom.offset_top = -104
	bottom.offset_bottom = -18
	bottom.add_theme_stylebox_override("panel", _style(Color(0.96, 0.94, 0.87, 0.93), 12, 14))
	var prompts := _column(bottom, 3)
	interaction = _label(prompts, "沿连廊前往高桌晚宴", 20)
	interaction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_hint = _label(prompts, "[WASD] 移动  [Shift] 小跑  [Tab] 手机  [Esc] 暂停", 15)
	controls_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_panel = _panel(root)
	toast_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	toast_panel.offset_left = -350
	toast_panel.offset_right = 350
	toast_panel.offset_top = -180
	toast_panel.offset_bottom = -108
	toast_label = _label(toast_panel, "", 21)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_panel.hide()

func build_photo_overlay() -> void:
	photo_overlay = Control.new()
	photo_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	photo_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(photo_overlay)
	for corner: Vector2 in [Vector2(0.25, 0.22), Vector2(0.75, 0.22), Vector2(0.25, 0.72), Vector2(0.75, 0.72)]:
		var mark := Label.new()
		mark.text = ("┌" if corner.x < 0.5 else "┐") if corner.y < 0.5 else ("└" if corner.x < 0.5 else "┘")
		mark.add_theme_font_size_override("font_size", 54)
		mark.add_theme_color_override("font_color", Color.WHITE)
		photo_overlay.add_child(mark)
		mark.anchor_left = corner.x
		mark.anchor_top = corner.y
		mark.position += Vector2(-20, -20)
	var panel := _panel(photo_overlay)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	panel.offset_left = -200
	panel.offset_right = 200
	panel.offset_top = 30
	panel.offset_bottom = 105
	photo_caption = _label(panel, "帮同学拍张照", 23)
	photo_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	photo_overlay.hide()

func build_phone() -> void:
	phone_panel = _panel(root)
	phone_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	phone_panel.offset_left = -354
	phone_panel.offset_right = -24
	phone_panel.offset_top = -560
	phone_panel.offset_bottom = -106
	phone_panel.add_theme_stylebox_override("panel", _style(Color("dbe8df"), 26, 24))
	phone_body = _column(phone_panel, 17)
	phone_panel.hide()

func sync_phone() -> void:
	phone_panel.visible = GameState.get_flag("phone_open") and not GameState.get_flag("game_finished") and not GameState.get_flag("paused") and not GameState.get_flag("modal_open")
	for child in phone_body.get_children():
		phone_body.remove_child(child)
		child.queue_free()
	_label(phone_body, "手机 · 消息", 28)
	_label(phone_body, "朋友 · 刚刚", 16, Color("657465"))
	_label(phone_body, "你到哪了？高桌晚宴快开始了，我在门口等你。", 22)
	if GameState.get_flag("responded_to_friend"):
		_label(phone_body, "你：在路上了，一会儿门口见。", 20, Color("547463"))
		var done := _button(phone_body, "已回复", func(): pass)
		done.disabled = true
	else:
		_button(phone_body, "回复", world.reply_to_friend)
		_button(phone_body, "稍后再说", world.ignore_friend)
	_label(phone_body, "[Tab] 收起手机\n看手机时会走得慢一些。", 16, Color("6c7569"))

func build_debug() -> void:
	debug_panel = _panel(root)
	debug_panel.position = Vector2(20, 172)
	debug_panel.size = Vector2(460, 425)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(420, 385)
	debug_panel.add_child(scroll)
	debug_label = _label(scroll, "演示状态", 16)
	debug_panel.hide()

func toggle_debug() -> void:
	if GameState.get_flag("game_finished"):
		if modal_kind == "replay":
			show_ending(world.last_result, "entered" if GameState.get_flag("reached_high_table") else "timeout")
		else:
			show_replay()
		return
	debug_panel.visible = not debug_panel.visible
	update_debug()

func update_debug() -> void:
	if not debug_panel.visible:
		return
	var task: Dictionary = world.tasks.get_task(GameState.get_value("current_task"))
	var lines: Array[String] = ["演示状态 · [F1] 关闭", "当前任务：" + str(task.get("name", ""))]
	for pair: Array in [["phone_open","手机已打开"],["responded_to_friend","已回复朋友"],["teacher_warned","被老师提醒"],["teacher_warned_twice","再次被提醒"],["helped_student","已帮助拍照"],["declined_photo","曾婉拒拍照"],["reached_high_table","已到达晚宴"]]:
		lines.append("%s：%s" % [pair[1], Text.yes_no(GameState.get_flag(pair[0]))])
	lines.append("游戏时间：" + GameState.format_time(GameState.get_value("current_game_time"), true))
	lines.append("最近事件")
	var count := EventLogger.events.size()
	for i in range(maxi(0, count - 8), count):
		var event: Dictionary = EventLogger.events[i]
		lines.append("%s  %s" % [event["game_time"], Text.event_name(event["event"])])
	debug_label.text = "\n".join(lines)

func _new_modal(kind: String, title: String, subtitle: String = "") -> VBoxContainer:
	for child in modal_layer.get_children():
		modal_layer.remove_child(child)
		child.queue_free()
	modal_kind = kind
	modal_layer.show()
	phone_panel.hide()
	toast_panel.hide()
	var shade := ColorRect.new()
	shade.color = Color(0.07, 0.14, 0.13, 0.7)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal_layer.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal_layer.add_child(center)
	var panel := _panel(center, 700)
	var layout := _column(panel, 16)
	var scroll := ScrollContainer.new()
	var height := 500.0
	if kind == "intro":
		height = 560.0
	elif kind == "dialogue":
		height = 380.0
	elif kind == "pause":
		height = 160.0
	scroll.custom_minimum_size = Vector2(660, height)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(scroll)
	modal_body = _column(scroll, 12)
	modal_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_footer = _column(layout, 8)
	_label(modal_body, title, 35)
	if not subtitle.is_empty():
		_label(modal_body, subtitle, 18, Color("697766"))
	return modal_body

func show_intro() -> void:
	GameState.set_flag("modal_open", true)
	var body := _new_modal("intro", "高桌晚宴前的校园", "校园微世界 · 一个会记住你选择的小故事")
	_label(body, "傍晚六点五十五分，朋友已经在宴会厅门口等你。\n沿连廊向前走，也可以拐去花园，顺手帮同学一个忙。", 21)
	_label(body, "选择本局任务", 20)
	var task_row := HBoxContainer.new()
	task_row.add_theme_constant_override("separation", 10)
	body.add_child(task_row)
	for task: Dictionary in world.tasks.presets.slice(0, 3):
		var id: String = task["id"]
		_button(task_row, task["name"], func(): select_task(id))
	task_description = _label(body, "", 20)
	select_task(selected_task)
	_label(body, "[WASD] 移动  [Shift] 小跑  [Tab] 手机\n靠近人物，出现提示后按 [E] 交谈。\n帮忙拍照会耽误约半分钟，走路看手机会变慢。\n[Esc] 暂停与操作说明  [F1] 演示状态", 17)
	_button(modal_footer, "开始赴宴", func(): world.start_run(selected_task))

func select_task(id: String) -> void:
	selected_task = id
	GameState.set_value("current_task", id)
	if is_instance_valid(task_description):
		var task: Dictionary = world.tasks.get_task(id)
		task_description.text = "已选：%s\n%s" % [task["name"], task["description"]]
		if id == "basic":
			task_description.text += "\n本任务只检查是否赴宴；迟到仍可完成。"

func show_dialogue(speaker: String, words: String, options: Array) -> void:
	GameState.set_flag("modal_open", true)
	var body := _new_modal("dialogue", speaker, "交谈中 · 时间暂时停留")
	_label(body, words, 24)
	for option: Dictionary in options:
		var callback: Callable = option["action"]
		if world.agent_mode:
			_label(modal_footer, option["text"], 20)
			continue
		_button(modal_footer, option["text"], func():
			close_modal()
			callback.call()
		)

func close_modal() -> void:
	modal_layer.hide()
	modal_kind = ""
	GameState.set_flag("modal_open", false)
	sync_phone()

func handle_escape() -> void:
	if GameState.get_flag("game_finished"):
		if modal_kind == "replay":
			show_ending(world.last_result, "entered" if GameState.get_flag("reached_high_table") else "timeout")
		else:
			world.quit_game()
		return
	if not GameState.get_flag("started"):
		return
	if modal_kind == "dialogue":
		# Arrival dialogue must be confirmed; otherwise the player could continue with frozen arrival state.
		toast("请先选择一项回应。")
		return
	if GameState.get_flag("paused"):
		resume_game()
	else:
		GameState.set_flag("paused", true)
		EventBus.emit_event("PAUSED", "world")
		var body := _new_modal("pause", "稍作停留", "已暂停，时间和人物动作都已停下。")
		_label(body, "[WASD] 移动  [Shift] 小跑\n[E] 与附近人物交谈  [Tab] 手机\n[Esc] 继续  [F1] 演示状态", 19)
		_button(modal_footer, "继续赴宴", resume_game)
		_button(modal_footer, "重新选择任务", world.restart)
		_button(modal_footer, "退出游戏", world.quit_game)

func resume_game() -> void:
	GameState.set_flag("paused", false)
	EventBus.emit_event("RESUMED", "world")
	close_modal()

func show_ending(result: Dictionary, reason: String) -> void:
	var subtitle := "朋友已经等到你了，今晚的故事先到这里。" if reason == "entered" else "晚宴已经开始一会儿了，这一局先到这里。"
	var body := _new_modal("ending", "高桌晚宴", "今晚的小故事")
	_label(body, Text.story_summary(GameState.snapshot()), 23)
	_label(body, "任务结果：" + ("成功" if result["success"] else "未完成"), 25, Color("426c58") if result["success"] else Color("98684d"))
	var task: Dictionary = world.tasks.get_task(result["task_id"])
	_label(body, "到达时间：%s    准时到达：%s" % [GameState.format_time(GameState.get_value("arrival_time"), true), Text.yes_no(GameState.get_flag("arrived_on_time"))], 21)
	_label(body, "回复朋友：%s    帮助同学拍照：%s\n被老师提醒：%s    再次被提醒：%s" % [Text.yes_no(GameState.get_flag("responded_to_friend")), Text.yes_no(GameState.get_flag("helped_student")), Text.yes_no(GameState.get_flag("teacher_warned")), Text.yes_no(GameState.get_flag("teacher_warned_twice"))], 20)
	_label(body, "本局任务：%s\n%s" % [task["name"], task["description"]], 20)
	for condition: Dictionary in result["details"]:
		var mark := "✓" if condition["passed"] else "×"
		var label: String = condition["label"]
		if not condition["passed"]:
			label = label.replace("已帮助", "未帮助").replace("已在", "未在").replace("已到达", "未到达").replace("没有因", "曾因")
		_label(body, "%s %s" % [mark, label], 20)
	_label(body, "本局事件和任务结果已保存在本机。" if not EventLogger.io_error else "日志写入失败，本局结果尚未完整保存。", 16)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	modal_footer.add_child(actions)
	_button(actions, "[R] 再玩一局", world.restart)
	_button(actions, "[Esc] 退出", world.quit_game)

func show_replay() -> void:
	var body := _new_modal("replay", "本局足迹", "按发生顺序查看记录；这里展示事件，不重放人物运动。")
	var records := EventLogger.read_last_run()
	for record: Dictionary in records:
		_label(body, "%s  %s" % [record["game_time"], Text.event_name(record["event"])], 19)
	_button(modal_footer, "返回本局总结", func(): show_ending(world.last_result, "entered" if GameState.get_flag("reached_high_table") else "timeout"))

func toast(words: String) -> void:
	if words == toast_label.text and toast_remaining > 0:
		return
	if not toast_queue.has(words):
		toast_queue.append(words)
	if toast_queue.size() > 4:
		toast_queue.pop_front()

func set_interaction(words: String) -> void:
	if world.player.photo_mode:
		interaction.text = "正在拍照 · 稍等片刻"
	elif GameState.get_flag("busy"):
		interaction.text = "对方正在转过身来……"
	elif GameState.get_flag("phone_open"):
		if world.teacher.pending_warning > 0:
			interaction.text = "老师注意到你了 · [Tab] 收起手机"
		elif world.teacher.bubble_remaining > 0 and world.teacher.bubble.text in ["走路注意看路，先把手机收一下。", "怎么又看上了？"]:
			interaction.text = "走路注意看路 · [Tab] 收起手机"
		else:
			interaction.text = "正在看手机 · [Tab] 收起手机"
	elif world.nearest:
		interaction.text = words
	elif not GameState.get_flag("responded_to_friend") and float(GameState.get_value("elapsed")) < 18:
		interaction.text = "朋友发来了消息 · [Tab] 查看手机"
	elif not GameState.get_flag("helped_student") and GameState.get_flag("photo_request_seen") and world.student.nearby(16):
		interaction.text = "右侧有同学招手 · 靠近后按 [E] 交谈"
	else:
		interaction.text = words

func flash_photo() -> void:
	flash_layer.color.a = 0.75

func _process(delta: float) -> void:
	if not is_instance_valid(time_label):
		return
	time_label.text = GameState.format_time(GameState.get_value("current_game_time", GameState.START_TIME))
	location_label.text = Text.LOCATIONS.get(GameState.get_value("current_location"), "校园")
	var task: Dictionary = world.tasks.get_task(GameState.get_value("current_task"))
	var goal := "前往晚宴门口，与朋友会合"
	if GameState.get_value("current_task") != "basic":
		goal = "19:00 前赴宴" if GameState.get_flag("helped_student") else "帮同学拍照，再去赴宴"
	if GameState.get_value("current_task") == "careful_student":
		goal += "\n留意脚下，别边走边看手机"
	if task.id not in ["basic", "helpful_student", "careful_student"]:
		goal = task.name
	objective.text = goal
	phone_status.visible = GameState.get_flag("phone_open")
	toast_panel.offset_left = -430 if GameState.get_flag("phone_open") else -350
	toast_panel.offset_right = 230 if GameState.get_flag("phone_open") else 350
	controls_hint.visible = world.agent_mode or float(GameState.get_value("elapsed")) < 12
	if world.agent_mode:
		controls_hint.text = world.agent_status + " · [F1] 调试信息"
		interaction.text = "本局演示完成" if GameState.get_flag("game_finished") else "程序正在操作校园角色"
		phone_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	photo_overlay.visible = world.player.photo_mode and not GameState.get_flag("paused")
	if world.player.photo_mode:
		var remaining: float = world.student.photo_remaining
		photo_caption.text = "拍好了！" if remaining <= 0.65 else ("站好了，准备拍照" if remaining > 2.3 else "看镜头 · %s" % int(ceil(remaining)))
	if not GameState.get_flag("paused"):
		flash_layer.color.a = move_toward(flash_layer.color.a, 0, delta * 2.5)
	if toast_remaining <= 0 and not toast_queue.is_empty() and not modal_layer.visible and not world.player.photo_mode:
		toast_label.text = toast_queue.pop_front()
		toast_remaining = clampf(toast_label.text.length() * 0.10, 2.5, 4.5)
	phone_panel.visible = GameState.get_flag("phone_open") and not (GameState.get_flag("game_finished") or GameState.get_flag("paused") or GameState.get_flag("modal_open"))
	if toast_remaining > 0 and not GameState.get_flag("paused") and not GameState.get_flag("modal_open"):
		toast_remaining -= delta
		toast_panel.visible = not modal_layer.visible and not GameState.get_flag("game_finished") and not world.player.photo_mode
		if toast_remaining <= 0:
			toast_panel.hide()
	refresh_elapsed += delta
	if refresh_elapsed >= 0.2:
		refresh_elapsed = 0
		update_debug()
