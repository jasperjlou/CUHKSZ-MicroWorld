extends CanvasLayer
const Text := preload("res://systems/ChineseText.gd")
var world: Node3D
var root: Control
var objective: Label
var clock_label: Label
var zone_label: Label
var prompt: Label
var debug: Label
var notice: Label
var notice_remaining := 0.0
var modal: Control
var choice_panel: PanelContainer
var choice_text: Label
var board_button: Button
var travel_overlay: ColorRect
var travel_text: Label

func _ready() -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var theme := Theme.new()
	theme.default_font = Text.FONT
	theme.default_font_size = 20
	root.theme = theme
	add_child(root)
	objective = label(root,"沿湖赴约",23)
	objective.position = Vector2(28,22)
	zone_label = label(root,"",17)
	zone_label.position = Vector2(28,88)
	clock_label = label(root,"",22)
	clock_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	clock_label.offset_left = -330
	clock_label.offset_right = -28
	clock_label.offset_top = 22
	clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	prompt = label(root,"",21)
	prompt.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	prompt.offset_top = -94
	prompt.offset_bottom = -18
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice = label(root,"",22)
	notice.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	notice.offset_top = 130
	notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	debug = label(root,"",17)
	debug.position = Vector2(28,155)
	debug.custom_minimum_size.x = 415
	debug.size.x = 415
	debug.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var debug_style := StyleBoxFlat.new()
	debug_style.bg_color = Color(0.08,0.16,0.14,0.94)
	debug_style.content_margin_left = 14
	debug_style.content_margin_right = 14
	debug_style.content_margin_top = 10
	debug_style.content_margin_bottom = 10
	debug.add_theme_stylebox_override("normal",debug_style)
	debug.visible = false
	travel_overlay = ColorRect.new()
	travel_overlay.color = Color(0.08,0.18,0.16,0.93)
	travel_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	travel_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	travel_overlay.visible = false
	root.add_child(travel_overlay)
	travel_overlay.z_index = -1
	travel_text = label(travel_overlay,"",25)
	travel_text.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	travel_text.offset_left = -290
	travel_text.offset_right = 290
	travel_text.offset_top = -60
	travel_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	travel_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func label(parent: Node, words: String, size: int = 20) -> Label:
	var result := Label.new()
	result.text = words
	result.add_theme_font_size_override("font_size",size)
	result.add_theme_color_override("font_color",Color("fff7df"))
	result.add_theme_color_override("font_shadow_color",Color("1f3633"))
	result.add_theme_constant_override("shadow_offset_x",1)
	result.add_theme_constant_override("shadow_offset_y",2)
	parent.add_child(result)
	return result

func _process(delta: float) -> void:
	var event: Dictionary = world.current_event()
	objective.text = "沿湖赴约\n%s 前到达下园方向出口" % GameState.format_time(event.start_time)
	var current: Dictionary = world.location_observation()
	zone_label.text = "接驳途中" if world.transport.riding else ""
	for zone: Dictionary in world.Zones.definitions():
		if zone.id == current.zone:
			zone_label.text = zone.name_zh
	var remaining := float(event.time_remaining)
	var timing := "活动开始还有 %d 分钟" % int(ceil(remaining/60.0))
	if remaining <= 60 and remaining > 0:
		timing = "活动开始还有 %d 秒" % int(ceil(remaining))
	if event.status == "active":
		timing = "活动已开始"
	elif event.status == "missed" or event.status == "completed":
		timing = "活动已结束"
	clock_label.text = GameState.format_time(WorldTime.current_time,true)+"\n"+timing
	travel_overlay.visible = world.transport.riding
	if world.transport.riding:
		travel_text.text = ("已上车，等候发车" if world.transport.shuttle.state == "boarding" else "接驳途中")+"\n预计抵达还有 %s\n\n本段使用简化乘车转场，时间持续推进。\n[Esc] 暂停或重新出发" % duration_text(maxf(0,world.transport.shuttle.destination_arrival-WorldTime.current_time))
	if is_instance_valid(choice_panel):
		if not world.transport.nearby() or world.finished or GameState.get_flag("modal_open") or world.transport.riding:
			close_choice()
		else:
			choice_text.text = transport_text()
			board_button.disabled = not world.transport.shuttle.can_board()
	if world.finished or GameState.get_flag("modal_open"):
		prompt.text = ""
	else:
		prompt.text = "[E] 查看" + str(world.records[world.nearest].name_zh) if world.nearest != "" else "[WASD] 移动　[Shift] 小跑　[Esc] 暂停"
		if world.nearest == "LowerCampus_Direction":
			prompt.text = "[E] 在出口签到，查看到达结果"
		elif world.nearest == world.transport.STOP_ID:
			prompt.text = "[E] 查看接驳班次，也可以直接沿步道前行"
		if world.transport.riding:
			prompt.text = ""
		else:
			prompt.text += "\n[C] " + ("回看湖边" if world.player.camera_offset.z < 0 else "转向林缘")+"　[V] 侧看道路 / 林坡"
	notice_remaining -= delta
	notice.visible = notice_remaining > 0 and not GameState.get_flag("modal_open") and not is_instance_valid(choice_panel)
	if debug.visible:
		var landmark: Dictionary = world.records.get(current.nearest_landmark,{})
		var evidence: Dictionary = landmark.get("evidence",{})
		var source_names: Array[String] = []
		for source: String in evidence.get("sources",[]):
			source_names.append(source.replace("VR_","全景 ").replace("LAKE_","湖区图 "))
		debug.text = "世界建设状态 · 按 [F1] 收起\n当前区域：%s\n最近地标：%s\n真实位置未经测绘配准\n%s\n[V] 侧看　[C] 前后看\n边界恢复：%d　无效动作：%d" % [zone_label.text,landmark.get("name_zh","暂无"),world.Ground.label_text(world.player.position),world.recovery_count,world.invalid_actions]

func toast(words: String) -> void:
	notice.text = words
	notice_remaining = 5.0

func close_modal() -> void:
	if is_instance_valid(modal):
		modal.queue_free()
		modal = null

func panel(title: String, words: String) -> VBoxContainer:
	close_modal()
	GameState.set_flag("modal_open",true)
	modal = ColorRect.new()
	modal.color = Color(0.06,0.13,0.12,0.72)
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(modal)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.add_child(center)
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(660,0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("243f3a")
	style.content_margin_left = 30
	style.content_margin_right = 30
	style.content_margin_top = 26
	style.content_margin_bottom = 26
	style.corner_radius_top_left = 14
	style.corner_radius_bottom_right = 14
	card.add_theme_stylebox_override("panel",style)
	center.add_child(card)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation",15)
	card.add_child(body)
	label(body,title,32)
	var description := label(body,words,20)
	description.custom_minimum_size.x = 600
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return body

func button(parent: Node, words: String, action: Callable) -> void:
	var b := Button.new()
	b.text = words
	b.custom_minimum_size.y = 46
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(action)
	parent.add_child(b)

func show_intro() -> void:
	var event: Dictionary = world.current_event()
	var words := "现在是 %s，交流活动将在 %s 开始，%s 结束。\n沿木栈道走到下园方向出口，按 [E] 签到。\n\n走走看看也要留意时间：每秒推进 %.1f 个游戏秒。\n活动为演示设定；出口真实接点、路宽和高差仍待核对。\n\n[WASD] 移动　[Shift] 小跑\n[E] 查看或签到　[Esc] 暂停　[F1] 演示状态" % [GameState.format_time(WorldTime.current_time),GameState.format_time(event.start_time),GameState.format_time(event.end_time),WorldTime.time_scale]
	var body := panel("沿湖赴约",words)
	label(body,"身后可逛入口广场和林缘路侧；赴约请沿湖走。",18)
	var scenarios := OptionButton.new()
	scenarios.name = "TransportScenario"
	scenarios.custom_minimum_size.y = 38
	var ids: Array = world.transport.config.scenarios.keys()
	for id: String in ids:
		scenarios.add_item(world.transport.config.scenarios[id].title_zh)
	scenarios.select(ids.find(world.transport.scenario_id))
	scenarios.item_selected.connect(func(index: int): world.transport.configure(ids[index]))
	body.add_child(scenarios)
	button(body,"开始漫步",world.start)
	button(body,"返回高桌晚宴",world.return_to_campus)

func show_pause() -> void:
	close_choice()
	var body := panel("在湖边歇一会儿", "[WASD] 移动　[Shift] 小跑\n[E] 查看地点　[F1] 演示状态\n沿木栈道向前，尽头的绿色指示牌就是本段终点。")
	button(body,"继续漫步",func(): close_modal(); GameState.set_flag("modal_open",false))
	button(body,"重新出发",world.restart)
	button(body,"返回高桌晚宴",world.return_to_campus)

func show_ending() -> void:
	close_choice()
	var result: Dictionary = world.result
	var stories := {"early":"你沿湖走到出口，活动还没开始，可以稍微歇一会儿。","on_time":"你赶在开始前到了出口，时间刚刚好。","late":"你走到出口时，活动已经开始了。","missed":"湖边多停留了一会儿，到出口时，活动已经结束了。"}
	var outcome := "提前 " + duration_text(float(result.earliness)) + "到达"
	if result.arrival_status == "on_time":
		outcome = "准时到达（距开始还有 %s）" % duration_text(float(result.earliness))
	elif result.arrival_status == "late":
		outcome = "迟到 " + duration_text(float(result.lateness))
	elif result.arrival_status == "missed":
		outcome = "已错过活动"
	var words := str(stories.get(result.arrival_status,"本局已结束。"))+"\n\n到达时间：%s\n活动时间：%s—%s\n%s\n任务结果：%s\n\n本局用时：%.1f 秒　行走：%.1f 游戏单位\n无效动作：%d　重开次数：%d\n\n这是下园方向的占位出口，尚未连接真实下园。" % [GameState.format_time(result.arrival_time,true),GameState.format_time(result.event_start_time),GameState.format_time(result.event_end_time),outcome,"成功" if result.success else "未完成",result.travel_time,result.path_length,result.invalid_actions,result.reset_count]
	if result.shuttle_used:
		words = words.replace("你沿湖走到出口","你乘接驳车来到出口").replace("你走到出口时","接驳车到达出口时").replace("湖边多停留了一会儿，到出口时","到达出口时")
	words += "\n出行：%s　改主意：%d 次\n候车：%s　乘车：%s" % ["接驳车" if result.shuttle_used else "步行",result.replanning_count,duration_text(result.waiting_time),duration_text(result.ride_time)]
	var body := panel("沿湖赴约 · 本局结果",words)
	# Keep the longer transport result readable at the existing minimum resolution.
	body.get_child(0).add_theme_font_size_override("font_size",28)
	body.get_child(1).add_theme_font_size_override("font_size",18)
	body.add_theme_constant_override("separation",10)
	button(body,"再走一遍",world.restart)
	button(body,"返回高桌晚宴",world.return_to_campus)

func duration_text(seconds: float) -> String:
	var total := maxi(0,int(ceil(seconds-0.00001)))
	return "%d 分 %d 秒" % [total/60,total%60] if total >= 60 else "%d 秒" % total

func close_choice() -> void:
	if is_instance_valid(choice_panel):
		choice_panel.queue_free()
		choice_panel = null

func transport_text() -> String:
	var shuttle: Dictionary = world.transport.shuttle.observe(WorldTime.current_time)
	var states := {"scheduled":"尚未到站","approaching":"正在进站","boarding":"正在上客","departed":"已离站","in_transit":"已离站","arrived":"本班车已结束"}
	var wait_text := "延误暂不明确" if shuttle.estimated_wait == null else "预计等候 "+duration_text(shuttle.estimated_wait)
	var arrival_text := "本班无法上车，可继续步行。"
	if shuttle.state in ["scheduled","approaching","boarding"]:
		arrival_text = "预计抵达时间未知" if shuttle.estimated_total_time == null else "上车即短暂停留，预计 %s 抵达" % GameState.format_time(WorldTime.current_time+shuttle.estimated_total_time,true)
	return "原型接驳候车点\n步行约 %s（正常步速）\n计划到站 %s　%s\n%s；乘车约 %s\n%s\n%s\n班次、站点和车程均为演示设定。" % [duration_text(world.transport.walking_eta()),GameState.format_time(shuttle.scheduled_arrival),states[shuttle.state],wait_text,duration_text(shuttle.ride_duration),arrival_text,"正在候车；可随时继续步行，时间不会暂停。" if world.transport.waiting else "候车窗口计时；点击继续步行或直接移动。"]

func show_choice() -> void:
	close_choice()
	choice_panel = PanelContainer.new()
	choice_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	choice_panel.offset_left = -448
	choice_panel.offset_right = -24
	choice_panel.offset_top = 135
	var style := StyleBoxFlat.new()
	style.bg_color = Color("243f3a")
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	choice_panel.add_theme_stylebox_override("panel",style)
	root.add_child(choice_panel)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation",8)
	choice_panel.add_child(body)
	choice_text = label(body,transport_text(),18)
	choice_text.custom_minimum_size.x = 388
	choice_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button(body,"在这里等车",func(): world.transport.choice("wait","选择在候车点等待"))
	button(body,"上车",func(): world.transport.board(world.transport.shuttle.definition.id))
	board_button = body.get_child(body.get_child_count()-1)
	board_button.disabled = not world.transport.shuttle.can_board()
	button(body,"继续步行",func(): world.transport.choice("walk","选择继续沿湖步行"); close_choice())
