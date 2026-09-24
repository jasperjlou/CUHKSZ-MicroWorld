extends Node
var runner: Node
var failures: Array = []
var checks := 0
func _ready() -> void:
	run.call_deferred()
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		push_error(label)
func frames(n: int) -> void:
	for i in n: await get_tree().process_frame
func capture(name: String) -> void:
	await frames(3)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://tests/artifacts/" + name + ".png")
func run() -> void:
	await frames(5)
	var ui: CanvasLayer = runner.panel
	DisplayServer.window_set_size(Vector2i(960, 640))
	await frames(8)
	await capture("benchmark-settings-small")
	check(ui.setup.get_global_rect().end.y <= get_viewport().get_visible_rect().size.y, "settings fit minimum window")
	check(ui.task_choice.item_count == 12 and ui.condition_choice.item_count == 3, "task and condition selectors")
	DisplayServer.window_set_size(Vector2i(1280, 800))
	await frames(5)
	ui.condition_choice.select(2)
	ui.task_choice.select(2)
	await capture("benchmark-settings")
	var rect: Rect2 = ui.episode_button.get_global_rect()
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = rect.get_center()
		get_viewport().push_input(event, true)
	await frames(3)
	check(runner.running, "real GUI click starts episode")
	var photo_seen := false
	for i in 15000:
		if not runner.running: break
		if is_instance_valid(runner.env.world) and runner.env.world.player.photo_mode and not photo_seen:
			photo_seen = true
			await capture("benchmark-photo")
		await get_tree().process_frame
	check(not runner.running and runner.rows.size() == 1 and runner.rows[0].success, "GUI episode finishes successfully")
	check(photo_seen, "actual photo camera rendered")
	check(ui.return_button.visible, "settings return available")
	await capture("benchmark-ui-ending")
	runner.save_json("user://benchmark/ui-qa.json", {"checks":checks, "failures":failures})
	print("BENCHMARK UI QA ", checks, " failures=", failures.size())
	get_tree().quit(0 if failures.is_empty() else 1)
