extends "res://tests/IntegrationQA.gd"
const Layout := preload("res://world/FairyLakeLayout.gd")
const Events := preload("res://systems/CampusEvents.gd")
var outcomes: Array[Dictionary] = []
var semantic_baseline := ""

func run() -> void:
	reparent(get_tree().root)
	Engine.set_meta("event_qa_running",true)
	render = "--event-render" in OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	await frames(8)
	semantic_baseline = JSON.stringify(Layout.objects())
	var event: Dictionary = world.task_config.event
	# Exact boundaries use the pure verifier, independently of frame cadence and movement.
	for row: Array in [[65939.0,"early",true],[65940.0,"on_time",true],[65999.999,"on_time",true],[66000.0,"on_time",true],[66000.001,"late",false],[66599.999,"late",false],[66600.0,"missed",false],[66601.0,"missed",false]]:
		var verdict := Events.evaluate(event,row[0])
		check(verdict.arrival_status == row[1] and verdict.success == row[2],"exact arrival boundary "+str(row[0]))
	var schedule := Events.new()
	schedule.reset([event],65220)
	check(schedule.observe(event.id,65220).status == "upcoming","generic event upcoming")
	schedule.update(66000)
	check(schedule.observe(event.id,66000).status == "active","generic event active at exact start")
	schedule.attend(event.id,66001)
	schedule.update(66600)
	check(schedule.observe(event.id,66600).status == "completed","attended event completes at end")
	schedule.reset([event],66600)
	check(schedule.observe(event.id,66600).status == "missed","unattended event missed at end")
	# The generic clock supports configurable rate, explicit wait costs, pause and reset.
	WorldTime.configure(100,3)
	WorldTime.tick(2)
	check(WorldTime.current_time == 106 and WorldTime.elapsed == 2,"single configurable time source")
	WorldTime.set_paused(true)
	WorldTime.tick(10)
	WorldTime.advance(50)
	check(WorldTime.current_time == 106,"paused clock rejects tick and explicit cost")
	WorldTime.reset()
	check(WorldTime.current_time == 100 and WorldTime.elapsed == 0,"clock reset restores initial time")
	WorldTime.configure(float(world.task_config.initial_time),float(world.task_config.time_scale))
	WorldTime.set_paused(true)
	world.event_system.reset([event],WorldTime.current_time)
	await frames(10)
	check(WorldTime.current_time == 65220,"intro does not advance clock")
	ui_audit(world.ui.root)
	await capture("v08-01-intro")
	await click_button("开始漫步")
	var observation: Dictionary = world.environment_api.observe()
	for field: String in ["current_time","event_start_time","time_remaining","event_status","destination","current_location","event","time_scale"]:
		check(observation.has(field),"structured time field "+field)
	check(observation.destination == "LowerCampus_Direction" and observation.destination_confidence == "placeholder","destination retains uncertain identity")
	check(is_equal_approx(observation.time_remaining,66000-WorldTime.current_time),"remaining time shares authoritative source")
	await press_physical(KEY_ESCAPE,false)
	var paused_at := WorldTime.current_time
	var elapsed_at := WorldTime.elapsed
	await frames(90)
	check(WorldTime.current_time == paused_at and WorldTime.elapsed == elapsed_at,"pause freezes time and duration")
	await click_button("继续漫步")
	var pos: Vector3 = world.player.position
	var waiting: Dictionary = await world.environment_api.step({"type":"wait","duration":20})
	check(waiting.ok and world.player.position.distance_to(pos) < 0.1,"wait advances clock without movement")
	for action: Dictionary in [{"type":"wait","duration":-1},{"type":"wait","duration":"20"},{"type":"wait","duration":true},{"type":"navigate","target":"FairyLake"},{"type":"inspect","target":"LowerCampus_Direction"}]:
		var invalid: Dictionary = await world.environment_api.step(action)
		check(not invalid.ok,"invalid action rejected "+str(action))
	check(world.invalid_actions == 5,"invalid action metric counts rejections")
	# Full early run using real held keyboard inputs and unchanged V0.7 geometry.
	for point: Vector3 in Layout.POINTS.slice(1):
		await walk_to(point)
	await press_physical(KEY_E,false)
	verify_result("early")
	ui_audit(world.ui.root)
	await capture("v08-02-early")
	# Three agent journeys plus a deliberate human idle period exercise temporal outcomes.
	await fresh_run()
	await navigate_exit()
	await wait_until(65970)
	await arrive("on_time")
	await capture("v08-03-on-time")
	await fresh_run()
	await idle_until(65680)
	for point: Vector3 in Layout.POINTS.slice(1):
		await walk_to(point)
	await press_physical(KEY_E,false)
	verify_result("late")
	await capture("v08-04-late-idle")
	await fresh_run()
	await wait_until(66060)
	check(world.current_event().status == "active","departure after activity starts")
	await capture("v08-05-active-hud")
	await navigate_exit()
	await arrive("late")
	await fresh_run()
	await navigate_exit()
	await wait_until(66601)
	check(world.current_event().status == "missed","world marks missed before final interaction")
	await arrive("missed")
	await capture("v08-06-missed")
	# Repeated resets restore the same starting world time, with a separate cumulative counter.
	for i in range(3):
		var count: int = world.reset_count
		world.restart()
		await frames(8)
		world = get_tree().current_scene
		check(WorldTime.current_time == 65220 and WorldTime.elapsed == 0 and world.current_event().status == "upcoming","repeat reset restores clock and event "+str(i))
		check(world.reset_count == count+1 and world.invalid_actions == 0 and world.result.is_empty(),"reset count persists while per-run metrics clear")
	check(JSON.stringify(Layout.objects()) == semantic_baseline,"all geographic evidence and geometry unchanged")
	await click_button("开始漫步")
	await wait_until(65240)
	var aborted_summary: String = EventLogger.summary_path
	var old_reset_count: int = world.reset_count
	world.restart()
	await frames(8)
	world = get_tree().current_scene
	var aborted: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(aborted_summary))
	check(aborted.result.arrival_status == "aborted" and aborted.result.arrival_time == null and not aborted.result.success,"in-progress reset records an interrupted task without inventing arrival")
	check(world.reset_count == old_reset_count+1 and WorldTime.current_time == 65220,"in-progress reset restores clock and increments count")
	if render:
		get_window().content_scale_size = Vector2i(960,640)
		DisplayServer.window_set_size(Vector2i(960,640))
		await frames(5)
		ui_audit(world.ui.root)
		await capture("v08-07-small-intro")
		await click_button("开始漫步")
		await navigate_exit()
		await arrive("early")
		ui_audit(world.ui.root)
		await capture("v08-08-small-ending")
		var restart_button := find_button(world.ui.root,"再走一遍")
		check(restart_button != null and get_viewport().get_visible_rect().encloses(restart_button.get_global_rect()),"small ending restart fully visible")
	var report := {"checks":checks,"failures":failures,"outcomes":outcomes,"screenshots":screenshot_names,"evidence":"Physical held-input and agent routes with actual clock progression; exact boundary unit checks are separate."}
	FileAccess.open("res://tests/artifacts/v08_event_render.json" if render else "res://tests/artifacts/v08_event_qa.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("EVENT QA: %d checks, %d failures" % [checks,failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)

func fresh_run() -> void:
	await click_button("再走一遍")
	await frames(8)
	world = get_tree().current_scene
	check(WorldTime.current_time == 65220 and WorldTime.elapsed == 0,"restart restores 18:07 and elapsed zero")
	check(world.events.is_empty() and not world.finished,"new run clears log and outcome")
	await click_button("开始漫步")

func navigate_exit() -> void:
	var response: Dictionary = await world.environment_api.step({"type":"navigate","target":"LowerCampus_Direction"})
	check(response.ok,"agent collision route reaches exit")
	check(world.recovery_count == 0,"no teleport recovery used")

func wait_until(target: float) -> void:
	var duration := target-WorldTime.current_time
	if duration > 0:
		var response: Dictionary = await world.environment_api.step({"type":"wait","duration":duration})
		check(response.ok,"physical wait reaches target world time")

func idle_until(target: float) -> void:
	var p: Vector3 = world.player.position
	while WorldTime.current_time < target:
		await frames(1)
	check(world.player.position.distance_to(p) < 0.1,"human idle advances event clock without movement")

func arrive(expected: String) -> void:
	var response: Dictionary = await world.environment_api.step({"type":"inspect","target":"LowerCampus_Direction"})
	check(response.ok,"agent signs in within interaction radius")
	verify_result(expected)

func verify_result(expected: String) -> void:
	check(world.finished and world.result.arrival_status == expected,"arrival classification: "+expected)
	var result: Dictionary = world.result
	var frozen_count: int = world.invalid_actions
	var frozen_events: int = EventLogger.events.size()
	world.reject_action("not_ready",{"type":"inspect"})
	check(world.invalid_actions == frozen_count and EventLogger.events.size() == frozen_events,"finished task metrics and terminal log cannot be mutated by later input")
	check(result.success == (expected in ["early","on_time"]),"success requires spatial arrival AND deadline")
	for field: String in ["success","arrival_time","event_start_time","lateness","travel_time","path_length","invalid_actions","reset_count"]:
		check(result.has(field),"required result metric "+field)
	check(is_equal_approx(result.arrival_time,WorldTime.current_time),"arrival time matches clock")
	check(is_equal_approx(result.travel_time,WorldTime.elapsed),"duration matches clock")
	check(is_equal_approx(result.game_travel_time,result.travel_time*WorldTime.time_scale),"game duration matches configured rate")
	check(result.path_length > 80 and result.path_length < 120,"physical route path length plausible")
	check(result.lateness == maxf(0,result.arrival_time-result.event_start_time),"lateness arithmetic")
	check(not EventLogger.io_error and FileAccess.file_exists(EventLogger.summary_path),"existing result logger writes summary")
	var stored: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(EventLogger.summary_path))
	check(stored.result.arrival_status == expected and stored.result.invalid_actions == world.invalid_actions,"persisted result agrees with world")
	var trajectory: Array = JSON.parse_string(FileAccess.get_file_as_string(EventLogger.run_path))
	var samples := 0
	var previous_time := 0.0
	for row: Dictionary in trajectory:
		check(float(row.game_time_seconds) >= previous_time,"trajectory time monotonic")
		previous_time = float(row.game_time_seconds)
		if row.event == "TRAJECTORY_SAMPLE":
			samples += 1
			check(row.data.position.size() == 3,"trajectory has actual position")
	check(samples > 5,"trajectory samples saved through EventLogger")
	check(trajectory[-1].event == "TASK_FINISHED","result is terminal logged event")
	outcomes.append(result.duplicate(true))
