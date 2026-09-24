extends CanvasLayer
const Text := preload("res://systems/ChineseText.gd")
const Config := preload("res://benchmark/BenchmarkConfig.gd")
var runner: Node
var root: Control
var setup: PanelContainer
var status_panel: PanelContainer
var status_label: Label
var error_label: Label
var provider_choice: OptionButton
var condition_choice: OptionButton
var task_choice: OptionButton
var model_input: LineEdit
var repetitions: SpinBox
var steps_input: SpinBox
var episode_button: Button
var batch_button: Button
var return_button: Button

func _ready() -> void:
	layer = 20
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var theme := Theme.new()
	theme.default_font = Text.FONT
	theme.default_font_size = 20
	root.theme = theme
	setup = PanelContainer.new()
	root.add_child(setup)
	setup.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	setup.offset_left = -420
	setup.offset_right = 420
	setup.offset_top = -290
	setup.offset_bottom = 290
	var style := StyleBoxFlat.new()
	style.bg_color = Color("213b36")
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	setup.add_theme_stylebox_override("panel", style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	setup.add_child(column)
	_label(column, "校园任务 · 模型行为评测", 30)
	_label(column, "固定模型，比较即时观察、历史与简短计划。", 18)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 10)
	column.add_child(grid)
	_label(grid, "服务", 20)
	provider_choice = OptionButton.new()
	provider_choice.add_item("模拟服务（非真实模型）")
	provider_choice.add_item("已配置的兼容模型服务")
	grid.add_child(provider_choice)
	_label(grid, "上下文条件", 20)
	condition_choice = OptionButton.new()
	for condition in Config.CONDITIONS:
		condition_choice.add_item(Config.CONDITION_NAMES[condition])
	grid.add_child(condition_choice)
	_label(grid, "单局任务", 20)
	task_choice = OptionButton.new()
	var tasks := preload("res://systems/TaskSystem.gd").new()
	for task in tasks.presets:
		task_choice.add_item(task.name)
		task_choice.set_item_metadata(task_choice.item_count - 1, task.id)
	grid.add_child(task_choice)
	_label(grid, "模型", 20)
	model_input = LineEdit.new()
	model_input.custom_minimum_size.x = 410
	grid.add_child(model_input)
	_label(grid, "每个任务重复局数", 20)
	repetitions = SpinBox.new()
	repetitions.min_value = 1
	repetitions.max_value = 100
	repetitions.value = 1
	grid.add_child(repetitions)
	_label(grid, "每局最多动作数", 20)
	steps_input = SpinBox.new()
	steps_input.min_value = 1
	steps_input.max_value = 100
	steps_input.value = 40
	grid.add_child(steps_input)
	error_label = _label(column, "", 17)
	error_label.custom_minimum_size.y = 65
	error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var buttons := HBoxContainer.new()
	column.add_child(buttons)
	episode_button = _button(buttons, "运行选中单局", func(): _start(false))
	batch_button = _button(buttons, "运行完整评测（全部任务与条件）", func(): _start(true))
	_button(column, "返回人类试玩", func(): get_tree().current_scene.ui.show(); queue_free())
	provider_choice.item_selected.connect(func(_index): _provider_changed())
	_provider_changed()
	status_panel = PanelContainer.new()
	root.add_child(status_panel)
	status_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	status_panel.offset_left = 20
	status_panel.offset_right = 345
	status_panel.offset_top = 175
	status_panel.offset_bottom = 310
	status_panel.add_theme_stylebox_override("panel", style)
	var status_column := VBoxContainer.new()
	status_panel.add_child(status_column)
	status_label = _label(status_column, "", 16)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return_button = _button(status_column, "返回评测设置", func(): status_panel.hide(); setup.show())
	return_button.hide()
	status_panel.hide()

func _provider_changed() -> void:
	var mock := provider_choice.selected == 0
	model_input.editable = not mock
	model_input.text = "流程模拟器（不调用模型）" if mock else OS.get_environment("LLM_MODEL")
	error_label.text = "模拟服务只验证任务与评测流程，结果不能作为模型能力比较。" if mock else "模型地址和密钥只从环境变量读取；等待响应时校园时间暂停。"

func _label(parent: Node, words: String, size: int) -> Label:
	var label := Label.new()
	label.text = words
	label.add_theme_font_size_override("font_size", size)
	parent.add_child(label)
	return label

func _button(parent: Node, words: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = words
	button.custom_minimum_size.y = 44
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _start(full: bool) -> void:
	if runner.running:
		return
	runner.config.provider = "mock" if provider_choice.selected == 0 else "openai_compatible"
	runner.config.model = "scripted-fixture-v1" if provider_choice.selected == 0 else model_input.text.strip_edges()
	runner.config.supports_seed = provider_choice.selected != 0 and OS.get_environment("LLM_SUPPORTS_SEED") == "1"
	runner.config.conditions = Config.CONDITIONS.duplicate() if full else [Config.CONDITIONS[condition_choice.selected]]
	runner.config.task_ids = [] if full else [task_choice.get_item_metadata(task_choice.selected)]
	runner.config.episodes = int(repetitions.value) if full else 1
	runner.config.max_steps = int(steps_input.value)
	setup.hide()
	return_button.hide()
	status_panel.show()
	runner.run_suite()

func show_error(message: String) -> void:
	setup.show()
	status_panel.hide()
	error_label.text = message

func update_status(message: String) -> void:
	status_label.text = ("模拟流程 · " if runner.config.provider == "mock" else "真实模型 · ") + message

func finished(summary: Dictionary, _path: String) -> void:
	status_label.text = ("模拟流程" if runner.config.provider == "mock" else "真实模型") + "已完成：%s 局，成功 %s 局。\n结果已保存，可返回设置继续运行。" % [summary.episodes, summary.successes]
	return_button.show()
