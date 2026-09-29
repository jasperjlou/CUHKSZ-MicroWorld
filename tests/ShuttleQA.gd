extends "res://tests/IntegrationQA.gd"
const Layout := preload("res://world/FairyLakeLayout.gd")
const Shuttle := preload("res://systems/ShuttleSystem.gd")
var outcomes: Array[Dictionary] = []
var original_geometry := ""

func run() -> void:
	reparent(get_tree().root)
	Engine.set_meta("shuttle_qa_running",true)
	render = "--shuttle-render" in OS.get_cmdline_user_args()
	await frames(8)
	original_geometry = JSON.stringify(Layout.objects())
	test_schedule()
	ui_audit(world.ui.root)
	await capture("v09-01-intro")
	# A: walking really beats this schedule without changing walking speed or map.
	world.transport.configure("walk_faster")
	await click_button("开始漫步")
	var obs: Dictionary = world.environment_api.observe()
	check(obs.walking.estimated_time < obs.shuttle.estimated_total_time,"A remaining physical walk ETA beats slow shuttle")
	for point: Vector3 in Layout.POINTS.slice(1):
		await walk_to(point)
	await sign_in("early","walk")
	await capture("v09-02-walk-ending")
	# B: board through the same Chinese UI as a human. Ride waits through WorldTime.
	await fresh("shuttle_faster")
	obs = world.environment_api.observe()
	check(obs.walking.estimated_time > obs.shuttle.estimated_total_time,"B fast shuttle ETA beats normal walk")
	await press_physical(KEY_E,false)
	ui_audit(world.ui.root)
	await capture("v09-03-choice")
	await click_button("在这里等车")
	var waiting_at := WorldTime.current_time
	var waiting_before: float = world.transport.waiting_time
	await wait_until(world.transport.shuttle.actual_arrival+1)
	check(world.transport.waiting and is_equal_approx(world.transport.waiting_time-waiting_before,WorldTime.current_time-waiting_at),"waiting records shared game time")
	check(world.environment_api.observe().transport_available,"boarding available only at nearby active stop")
	await capture("v09-04-boarding")
	if render:
		world.ui.close_choice()
		await capture("v09-bus-visual")
		await press_physical(KEY_E,false)
	await click_button("上车")
	check(world.transport.riding and not world.player.is_physics_processing(),"ride locks physical player without freezing clock")
	var riding_observation: Dictionary = world.environment_api.observe()
	check(riding_observation.position_mode == "transport_anchor" and not riding_observation.shuttle_stop.nearby and riding_observation.current_location.begins_with("transport:"),"rider observation does not pretend passenger is still waiting at stop")
	await wait_until(world.transport.shuttle.departure_time+1)
	await capture("v09-05-transit")
	await press_physical(KEY_ESCAPE,false)
	var paused_time := WorldTime.current_time
	await frames(60)
	check(WorldTime.current_time == paused_time,"pause freezes transit and event countdown")
	await click_button("继续漫步")
	await wait_until(world.transport.shuttle.destination_arrival+1)
	check(not world.transport.riding and world.player.is_physics_processing() and world.player.model.visible,"arrival restores controls and player")
	check(world.player.position.distance_to(Layout.POINTS[-1]) < 0.5,"transport abstraction reaches designated endpoint")
	check(world.player.camera.global_position.is_finite(),"arrival camera finite")
	check(world.transport.ride_time >= 119.9 and world.transport.ride_time <= 120.1,"ride duration is shared-clock delta")
	await sign_in("early","shuttle")
	check(world.result.path_length < 2,"abstract transport displacement excluded from walking distance")
	await capture("v09-06-shuttle-ending")
	# C: observe delay, wait until scheduled time, then explicitly replan to walk.
	await fresh("delayed")
	await wait_until(world.transport.shuttle.scheduled_arrival+1)
	check(world.transport.shuttle.state == "scheduled","C scheduled time passes but delayed bus absent")
	var replan: Dictionary = await world.environment_api.step({"type":"continue_walking","reason":"延误后预计乘车到达会迟到，改为步行"})
	check(replan.ok and world.transport.replanning_count == 1,"C cancel waiting increments replanning once")
	await navigate("LowerCampus_Direction")
	await sign_in("early","walk")
	check(world.result.waiting_time >= 120 and not world.result.shuttle_used,"C waiting cost preserved after walking")
	await capture("v09-07-replanned-ending")
	# D: indefinite human-style waiting is permitted, not automatically rescued.
	await fresh("missed")
	await wait_until(float(world.task_config.event.end_time)+1)
	check(world.current_event().status == "missed","D waiting can miss event")
	await navigate("LowerCampus_Direction")
	await sign_in("missed","walk")
	await capture("v09-08-missed-ending")
	# The same arrival verifier must also classify late and missed transport arrivals.
	for scenario: String in ["delayed","missed"]:
		await fresh(scenario)
		await wait_until(world.transport.shuttle.actual_arrival+1)
		var board: Dictionary = await world.environment_api.step({"type":"board","shuttle_id":"prototype_shuttle_01","reason":"继续等待并乘坐本班原型接驳车"})
		check(board.ok,"delayed boarding remains a legal choice")
		await wait_until(world.transport.shuttle.destination_arrival+1)
		await sign_in("late" if scenario == "delayed" else "missed","shuttle")
		await capture("v09-late-shuttle" if scenario == "delayed" else "v09-missed-shuttle")
	# Human movement itself can abandon the waiting choice without a dialogue button.
	await fresh("delayed")
	world.transport.choice("wait")
	await walk_to(Layout.POINTS[1])
	check(not world.transport.waiting and world.transport.replanning_count == 1,"physical departure cancels waiting exactly once")
	# E: early, remote, unknown and departed boarding must be counted as invalid.
	await fresh("shuttle_faster")
	await invalid_board("prototype_shuttle_01","shuttle_not_boarding_or_full")
	await invalid_board("missing_bus","unknown_shuttle")
	await navigate("FairyLake_Path_02")
	await invalid_board("prototype_shuttle_01","outside_boarding_zone")
	await navigate("Prototype_Shuttle_Stop")
	await wait_until(world.transport.shuttle.departure_time+1)
	await invalid_board("prototype_shuttle_01","shuttle_not_boarding_or_full")
	check(world.invalid_actions == 4,"E invalid boarding metrics count all four")
	# F: reset waiting, boarding, in_transit and arrival. Each restores all layers.
	for phase: String in ["waiting","boarding","in_transit","arrived"]:
		await fresh("shuttle_faster")
		if phase == "waiting":
			world.transport.choice("wait")
			await wait_until(WorldTime.initial_time+20)
		else:
			await wait_until(world.transport.shuttle.actual_arrival+1)
			if phase in ["in_transit","arrived"]:
				var board: Dictionary = await world.environment_api.step({"type":"board","shuttle_id":"prototype_shuttle_01"})
				check(board.ok,"F boards before reset "+phase)
				await wait_until(world.transport.shuttle.departure_time+1 if phase == "in_transit" else world.transport.shuttle.destination_arrival+1)
		var count: int = world.reset_count
		var summary_path: String = EventLogger.summary_path
		world.restart()
		await frames(8)
		world = get_tree().current_scene
		check(world.reset_count == count+1 and WorldTime.current_time == 65220 and WorldTime.elapsed == 0,"F clock reset "+phase)
		check(world.transport.shuttle.state == "scheduled" and not world.transport.riding and not world.transport.waiting,"F transport reset "+phase)
		check(world.transport.boarding_time == null and world.transport.waiting_time == 0 and world.transport.replanning_count == 0,"F metrics reset "+phase)
		check(world.player.position.distance_to(Layout.POINTS[0]) < 0.5 and world.player.is_physics_processing() and not GameState.get_flag("busy"),"F physical player restored "+phase)
		check(world.events.is_empty() and world.result.is_empty() and world.environment_api.observe().shuttle.state == "scheduled","F logging and observation reset "+phase)
		var stored: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(summary_path))
		check(stored.result.arrival_status == "aborted" and stored.result.arrival_time == null,"F unfinished reset logs no false arrival "+phase)
	check(JSON.stringify(Layout.objects()) == original_geometry,"V07 geometry and evidence untouched")
	if render:
		get_window().content_scale_size = Vector2i(960,640)
		DisplayServer.window_set_size(Vector2i(960,640))
		await frames(5)
		ui_audit(world.ui.root)
		await capture("v09-09-small-intro")
		await click_button("开始漫步")
		await press_physical(KEY_E,false)
		ui_audit(world.ui.root)
		await capture("v09-10-small-choice")
		await wait_until(world.transport.shuttle.actual_arrival+1)
		await click_button("上车")
		await wait_until(world.transport.shuttle.destination_arrival+1)
		await sign_in("early","shuttle")
		ui_audit(world.ui.root)
		var again := find_button(world.ui.root,"再走一遍")
		check(get_viewport().get_visible_rect().encloses(again.get_global_rect()),"small ending buttons visible")
		await capture("v09-11-small-ending")
	var report := {"checks":checks,"failures":failures,"outcomes":outcomes,"screenshots":screenshot_names,"evidence":"Automated physical walking and explicit transport abstraction. No real-model or first-time-human claims."}
	FileAccess.open("res://tests/artifacts/v09_render.json" if render else "res://tests/artifacts/v09_qa.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("SHUTTLE QA: %d checks, %d failures" % [checks,failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)

func test_schedule() -> void:
	var cfg: Dictionary = world.transport.shuttle.definition.duplicate(true)
	var schedule := Shuttle.new()
	schedule.reset(cfg,65220)
	check(schedule.state == "scheduled","schedule starts scheduled")
	schedule.update(schedule.actual_arrival-1)
	check(schedule.state == "approaching","approach before boarding")
	schedule.update(schedule.actual_arrival)
	check(schedule.can_board(),"exact arrival opens boarding")
	schedule.update(schedule.departure_time)
	check(schedule.state == "in_transit" and not schedule.can_board(),"exact departure closes boarding")
	schedule.update(schedule.destination_arrival)
	check(schedule.state == "arrived","exact destination time arrives")
	cfg.delay_jitter = 240
	cfg.scenario_seed = 42
	schedule.reset(cfg,65220)
	var first := schedule.actual_arrival
	schedule.reset(cfg,65220)
	check(schedule.actual_arrival == first,"seeded delay reproducible")
	cfg.information_mode = "partial"
	schedule.reset(cfg,65220)
	var partial := schedule.observe(65220)
	check(partial.actual_arrival == null and partial.estimated_delay == null and partial.estimated_total_time == null and partial.departure_time == null,"partial observation hides actual future delay and derived timings")
	check(not partial.has("best_choice"),"no decision oracle in observation")
	cfg.capacity = 0
	schedule.reset(cfg,65220)
	schedule.update(schedule.actual_arrival)
	check(not schedule.can_board(),"zero capacity refuses boarding")

func fresh(scenario: String) -> void:
	world.restart()
	await frames(8)
	world = get_tree().current_scene
	world.transport.configure(scenario)
	await click_button("开始漫步")

func wait_until(time: float) -> void:
	if time > WorldTime.current_time:
		var response: Dictionary = await world.environment_api.step({"type":"wait","duration":time-WorldTime.current_time})
		check(response.ok,"wait advances unified clock")

func navigate(target: String) -> void:
	var response: Dictionary = await world.environment_api.step({"type":"navigate","target":target})
	check(response.ok and world.recovery_count == 0,"existing physical navigation: "+target)

func invalid_board(id: String, expected: String) -> void:
	var response: Dictionary = await world.environment_api.step({"type":"board","shuttle_id":id})
	check(not response.ok and response.reason == expected,"invalid boarding: "+expected)

func sign_in(status: String, mode: String) -> void:
	var response: Dictionary = await world.environment_api.step({"type":"inspect","target":"LowerCampus_Direction"})
	check(response.ok and world.finished,"spatial sign-in completes task")
	check(world.result.arrival_status == status and world.result.transport_mode == mode,"time and transport result: "+status+"/"+mode)
	for field: String in ["success","arrival_time","lateness","travel_time","path_length","invalid_actions","reset_count","transport_mode","waiting_time","shuttle_used","scheduled_arrival","actual_arrival","delay","boarding_time","ride_time","replanning_count"]:
		check(world.result.has(field),"result field "+field)
	var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(EventLogger.summary_path))
	for key: String in world.result:
		var value: Variant = world.result[key]
		if value is float or value is int:
			check(is_equal_approx(float(saved.result[key]),float(value)),"persisted numeric metric "+key)
		else:
			check(saved.result[key] == value,"persisted metric "+key)
	check(world.events[-1].event == "TASK_FINISHED","terminal event remains final")
	var choice_logged := false
	var transit_sample := false
	var abstract_arrival := false
	var previous := 0.0
	for row: Dictionary in world.events:
		check(float(row.game_time_seconds) >= previous,"unified trajectory time monotonic")
		previous = row.game_time_seconds
		choice_logged = choice_logged or row.event == "TRANSPORT_CHOICE"
		transit_sample = transit_sample or (row.event == "TRAJECTORY_SAMPLE" and row.data.get("in_transport",false))
		abstract_arrival = abstract_arrival or (row.event == "TRANSPORT_ARRIVED" and row.data.get("transport_abstraction",false))
	check(choice_logged,"trajectory includes choice and observation context")
	if mode == "shuttle":
		check(transit_sample and abstract_arrival,"transport trajectory explicitly marks transit and abstract relocation")
	check(world.player.camera.global_position.is_finite(),"finite ending camera")
	outcomes.append(world.result.duplicate(true))
