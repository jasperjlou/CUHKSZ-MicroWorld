extends Node3D
const Journey := preload("res://world/JourneyLayout.gd")
var full_journey := false
var completed_visits: Array[String] = []
var visited_zones: Array[String] = []
var walking_time := 0.0
var wrong_branch_count := 0
var branch_replanning_count := 0
var active_detour := ""
const Layout := preload("res://world/FairyLakeLayout.gd")
var player: CharacterBody3D
var ui: CanvasLayer
var builder: Node3D
var environment_api: RefCounted
var elapsed: float:
	get: return WorldTime.elapsed
var travelled := 0.0
var seen: Array[String] = []
var inspected: Array[String] = []
var nearest := ""
var finished := false
var recovery_count := 0
var last_safe := Vector3.ZERO
var previous := Vector3.ZERO
var events: Array[Dictionary]:
	get: return EventLogger.events
var records: Dictionary = {}
var event_system := preload("res://systems/CampusEvents.gd").new()
var task_config: Dictionary = {}
var result: Dictionary = {}
var invalid_actions := 0
var reset_count := 0
var trajectory_sample_at := 0.0
var transport: Node3D
const Entrance := preload("res://world/EntranceLayout.gd")
const Connector := preload("res://world/ForestConnectorLayout.gd")
const Zones := preload("res://systems/CampusZones.gd")
const Survey := preload("res://systems/FrontierSurvey.gd")
const Ground := preload("res://systems/GroundSurvey.gd")
const Junction := preload("res://world/JunctionLayout.gd")
var path_graph: RefCounted
var route_points: Array[Vector3] = Connector.route_points()
var current_zone := ""

func current_event() -> Dictionary:
	return event_system.observe(task_config.event.id,WorldTime.current_time)

func _ready() -> void:
	full_journey = bool(Engine.get_meta("full_journey",false))
	DisplayServer.window_set_title("校园微世界：跨园赴约" if full_journey else "校园微世界：神仙湖漫步")
	preload("res://systems/CampusInput.gd").configure()
	GameState.reset()
	EventBus.reset()
	EventLogger.prepare_next_run()
	task_config = Journey.definition() if full_journey else JSON.parse_string(FileAccess.get_file_as_string("res://tasks/lake_event.json"))
	reset_count = int(Engine.get_meta("lake_reset_count",0))
	WorldTime.configure(float(task_config.initial_time),float(task_config.time_scale))
	GameState.set_value("current_task",task_config.task_id)
	GameState.set_value("current_location",task_config.start if full_journey else "UpperCampus_Direction")
	event_system.reset([task_config.event],WorldTime.current_time)
	event_system.status_changed.connect(_on_event_status)
	WorldTime.advanced.connect(func(_previous: float, now: float): event_system.update(now))
	for record: Dictionary in Layout.objects()+Entrance.objects()+Connector.objects()+Junction.objects():
		records[record.id] = record
	if full_journey:
		for record: Dictionary in Journey.objects():
			records[record.id] = record
	builder = preload("res://world/FairyLakeBuilder.gd").new()
	add_child(builder)
	preload("res://world/LakeReferenceDetails.gd").apply(builder)
	preload("res://world/JunctionBuilder.gd").build(builder,full_journey)
	if full_journey:
		preload("res://world/JourneyBuilder.gd").build(builder)
	path_graph = preload("res://world/CampusPathGraph.gd").new(route_points)
	if full_journey:
		for anchor: Dictionary in task_config.anchors:
			path_graph.ids[anchor.id] = path_graph.ids[anchor.alias]
	add_child(preload("res://systems/SoundCues.gd").new())
	player = preload("res://player/Player.tscn").instantiate()
	player.camera_offset = Vector3(0,9.4,16.5)
	player.position = (Layout.position_of(records[task_config.start]) if full_journey else Layout.POINTS[0])+Vector3.UP*0.1
	add_child(player)
	player.camera.fov = 55
	player.model.rotation.y = PI
	last_safe = player.position
	previous = player.position
	transport = preload("res://systems/LakeTransport.gd").new()
	transport.world = self
	add_child(transport)
	environment_api = preload("res://agents/FairyLakeEnvironment.gd").new(self)
	ui = preload("res://ui/FairyLakeUI.gd").new()
	ui.world = self
	add_child(ui)
	GameState.set_flag("modal_open",true)
	ui.show_intro()
	WorldTime.set_paused(true)
	EventLogger.write_failed.connect(func(): ui.toast("本局记录暂时无法写入，请检查存储空间。"))
	if full_journey and "--cross-campus-agent" in OS.get_cmdline_user_args():
		var runner: Node = preload("res://agents/CrossCampusRunner.gd").new()
		runner.world = self
		add_child(runner)
	if full_journey and not Engine.has_meta("cross_campus_qa_running") and ("--cross-campus-qa" in OS.get_cmdline_user_args() or "--cross-campus-render" in OS.get_cmdline_user_args()):
		var qa: Node = load("res://tests/CrossCampusQA.gd").new()
		qa.world = self
		add_child(qa)
	if not Engine.has_meta("junction_qa_running") and ("--junction-qa" in OS.get_cmdline_user_args() or "--junction-render" in OS.get_cmdline_user_args()):
		var qa: Node = load("res://tests/JunctionQA.gd").new()
		qa.world = self
		add_child(qa)
	if not Engine.has_meta("connector_qa_running") and ("--connector-qa" in OS.get_cmdline_user_args() or "--connector-render" in OS.get_cmdline_user_args()):
		var qa: Node = load("res://tests/ConnectorQA.gd").new()
		qa.world = self
		add_child(qa)
	if not Engine.has_meta("journey_qa_running") and ("--journey-qa" in OS.get_cmdline_user_args() or "--journey-render" in OS.get_cmdline_user_args()):
		var qa: Node = load("res://tests/JourneyQA.gd").new()
		qa.world = self
		add_child(qa)
	if not Engine.has_meta("shuttle_qa_running") and ("--shuttle-qa" in OS.get_cmdline_user_args() or "--shuttle-render" in OS.get_cmdline_user_args()):
		var qa: Node = load("res://tests/ShuttleQA.gd").new()
		qa.world = self
		add_child(qa)
	if not Engine.has_meta("event_qa_running") and ("--event-qa" in OS.get_cmdline_user_args() or "--event-render" in OS.get_cmdline_user_args()):
		var qa: Node = load("res://tests/WorldTimeEventQA.gd").new()
		qa.world = self
		add_child(qa)
	if not Engine.has_meta("lake_qa_running") and ("--lake-qa" in OS.get_cmdline_user_args() or "--lake-render" in OS.get_cmdline_user_args()):
		var qa := preload("res://tests/FairyLakeQA.gd").new()
		qa.world = self
		add_child(qa)

func start() -> void:
	if GameState.get_flag("started"):
		return
	EventLogger.begin_run()
	WorldTime.set_paused(false)
	GameState.set_flag("started",true)
	GameState.set_flag("modal_open",false)
	ui.close_modal()
	record_event("SLICE_STARTED",{"task":task_config,"reset_count":reset_count,"event":current_event(),"transport":transport.metrics()})

func record_event(kind: String, payload: Dictionary) -> void:
	var data := payload.duplicate(true)
	if is_instance_valid(player):
		data.position = [player.position.x,player.position.y,player.position.z]
	data.region = "cross_campus_journey" if full_journey else "fairy_lake_slice"
	EventBus.emit_event(kind,"lake_world",data)

func _on_event_status(id: String, before: String, after: String) -> void:
	if not GameState.get_flag("started"):
		return
	record_event("CAMPUS_EVENT_STATUS_CHANGED",{"id":id,"before":before,"after":after})
	if is_instance_valid(ui):
		var messages := {"active":"活动开始了，继续前往出口签到。","missed":"活动已经结束，这次错过了。到出口可以查看本局结果。","completed":"活动已经结束。"}
		if messages.has(after):
			ui.toast(str(messages[after]).replace("出口","下园活动广场") if full_journey else messages[after])

func reject_action(reason: String, action: Dictionary) -> Dictionary:
	if finished or not GameState.get_flag("started"):
		return {"ok":false,"reason":reason}
	invalid_actions += 1
	record_event("AGENT_INVALID_ACTION",{"reason":reason,"action":action})
	return {"ok":false,"reason":reason}

func _track_movement() -> void:
	travelled += Vector2(player.position.x-previous.x,player.position.z-previous.z).length()
	previous = player.position

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or not GameState.get_flag("started") or finished:
		return
	WorldTime.set_paused(GameState.get_flag("paused") or GameState.get_flag("modal_open") or (GameState.get_flag("busy") and not transport.riding))
	WorldTime.tick(delta)
	if GameState.can_move():
		if full_journey and player.moving:
			walking_time += delta*WorldTime.time_scale
		_track_movement()
	if not WorldTime.paused and elapsed >= trajectory_sample_at:
		record_event("TRAJECTORY_SAMPLE",{"event_status":current_event().status,"transport_state":transport.shuttle.state,"in_transport":transport.riding})
		trajectory_sample_at = elapsed+1.0
	if transport.riding:
		return
	if player.is_on_floor():
		last_safe = player.position
	if player.position.y < -4:
		# Emergency recovery only, never part of navigation or successful QA.
		player.position = last_safe+Vector3.UP*0.1
		player.velocity = Vector3.ZERO
		previous = player.position
		recovery_count += 1
		record_event("BOUNDARY_RECOVERY",{})
	nearest = ""
	var closest := 3.3
	for id: String in records:
		var record: Dictionary = records[id]
		var distance := player.position.distance_to(Layout.position_of(record))
		if record.landmark and distance < (48 if id == "FairyLake" else 15) and id not in seen:
			seen.append(id)
			record_event("LANDMARK_OBSERVED",{"id":id})
		if record.interactable and distance <= closest:
			closest = distance
			nearest = id
	if transport.nearby():
		nearest = transport.STOP_ID
	GameState.set_value("current_location",_current_location())
	var zone: String = location_observation().zone
	if zone != current_zone:
		record_event("ZONE_ENTERED",{"from":current_zone,"to":zone,"confidence":location_observation().confidence})
		current_zone = zone
		if zone not in visited_zones:
			visited_zones.append(zone)
	if full_journey:
		track_journey_progress()

func _current_location() -> String:
	var closest := INF
	var location := "fairy_lake_slice"
	for id: String in records:
		if not records[id].destination:
			continue
		var distance := player.position.distance_to(Layout.position_of(records[id]))
		if distance <= closest:
			closest = distance
			location = id
	return location

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_panel"):
		ui.debug.visible = not ui.debug.visible
	elif event.is_action_pressed("look_around") and GameState.can_move() and not player.agent_controlled:
		player.camera_offset = Vector3(0,9.4,16.5) if player.camera_offset.z < 0 else Vector3(0,6,-19)
		player.update_camera(1,true)
	elif event.is_action_pressed("look_side") and GameState.can_move() and not player.agent_controlled:
		player.camera_offset = Vector3(12,8,0) if player.camera_offset.x < 0 else Vector3(-12,8,0)
		player.update_camera(1,true)
	elif event.is_action_pressed("pause_game") and GameState.get_flag("started") and not finished:
		if GameState.get_flag("modal_open"):
			ui.close_modal()
			GameState.set_flag("modal_open",false)
		else:
			ui.show_pause()
	elif event.is_action_pressed("interact") and GameState.can_move():
		interact(nearest)
	elif event.is_action_pressed("restart") and finished:
		restart()

func interact(id: String) -> bool:
	if not GameState.can_move() or not records.has(id):
		return false
	var record: Dictionary = records[id]
	if not record.interactable or player.position.distance_to(Layout.position_of(record)) > 3.3:
		return false
	if id not in inspected:
		inspected.append(id)
	record_event("LANDMARK_INSPECTED",{"id":id})
	if id == transport.STOP_ID:
		ui.show_choice()
	elif id == str(task_config.event.location):
		finish_task()
	elif full_journey and id == "FairyLake_Viewpoint_01":
		ui.toast("已到湖畔观景处。接下来原路返回岔路，沿下园支路前往活动广场。")
	elif full_journey and id == "LowerCampus_Direction":
		ui.toast("这里是湖边步道尽头。下园活动广场在岔路的下园支路，请返回岔路。")
	elif id in Connector.IDS.slice(1):
		ui.toast("沿路侧步道可到第一岔路。连接按现有资料推定，实际位置可再调整。")
	elif records[id].has("replaceable"):
		ui.toast("%s：%s，可原路返回岔路。当前位置和道路布局可随新资料调整。" % [record.name_zh,Survey.confidence_zh(record.confidence)])
	elif id.begins_with("Entrance_"):
		ui.toast("这里依据入口全景重建；继续通往上园的真实连接仍待核实。")
	elif id == "FairyLake_Viewpoint_01":
		ui.toast("湖水就在栏杆外，沿着岸线，前方是白色圆亭。")
	else:
		ui.toast("从题字石旁出发，沿湖边步道向前走。")
	return true

func restart() -> void:
	if GameState.get_flag("started") and not finished:
		finish_task(false,false)
	Engine.set_meta("lake_reset_count",reset_count+1)
	get_tree().reload_current_scene()

func finish_task(arrived: bool = true, show_ui: bool = true) -> void:
	if finished:
		return
	_track_movement()
	result = event_system.attend(task_config.event.id,WorldTime.current_time,float(task_config.near_start_seconds)) if arrived else {"success":false,"arrival_time":null,"arrival_status":"aborted","event_start_time":task_config.event.start_time,"event_end_time":task_config.event.end_time,"lateness":null,"earliness":null}
	result.merge({"task_id":task_config.task_id,"event_id":task_config.event.id,"destination":task_config.event.location,"destination_confidence":"placeholder","travel_time":elapsed,"game_travel_time":WorldTime.current_time-float(task_config.initial_time),"path_length":travelled,"path_length_unit":"game_units","invalid_actions":invalid_actions,"reset_count":reset_count,"reached_destination":arrived,"event_status":current_event().status,"time_scale":WorldTime.time_scale})
	result.merge(transport.metrics())
	if full_journey:
		result.merge(journey_metrics(),true)
		result.destination_confidence = records[task_config.event.location].confidence
		result.success = result.success and completed_visits.size() == task_config.required_visits.size()
		result.required_visits_complete = completed_visits.size() == task_config.required_visits.size()
	finished = true
	GameState.set_flag("game_finished",true)
	GameState.set_value("arrival_time",WorldTime.current_time if arrived else -1.0)
	GameState.set_value("arrived_on_time",bool(result.success))
	WorldTime.set_paused(true)
	record_event("TASK_FINISHED",result)
	EventLogger.finish_run(result)
	if show_ui:
		ui.show_ending()

func return_to_campus() -> void:
	if GameState.get_flag("started") and not finished:
		finish_task(false,false)
	Engine.remove_meta("lake_reset_count")
	Engine.remove_meta("full_journey")
	# The CLI is a one-time launch request; returning must not immediately redirect.
	Engine.set_meta("lake_launch_consumed",true)
	get_tree().change_scene_to_file("res://world/MainWorld.tscn")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and GameState.get_flag("started") and not finished:
		finish_task(false,false)

func location_observation() -> Dictionary:
	var zone := Zones.locate(player.position,transport.nearby(),transport.riding)
	if full_journey and not transport.riding and not transport.nearby():
		var anchored_zone := Journey.zone_at(player.position)
		if not anchored_zone.is_empty():
			zone = anchored_zone
	var confidence := "placeholder"
	for definition: Dictionary in Zones.definitions():
		if definition.id == zone:
			confidence = definition.confidence
	var closest := INF
	var landmark := ""
	var path := ""
	var path_distance := INF
	for id: String in records:
		var record: Dictionary = records[id]
		var distance := player.position.distance_to(Layout.position_of(record))
		if record.landmark and distance <= closest:
			closest = distance
			landmark = id
		if record.walkable and record.destination and distance <= path_distance:
			path_distance = distance
			path = id
	if player.position.z > 112:
		var section := Junction.section(player.position)
		confidence = section.confidence
	return {"zone":zone,"nearest_landmark":landmark,"semantic_path":path,"confidence":confidence,"global_connection_verified":false,"frontier_id":Survey.ID if zone == Connector.ZONE else "","geographic_anchor":"not_surveyed","replaceable":true}

func journey_metrics() -> Dictionary:
	return {"walking_time":walking_time,"time_unit":"game_seconds","wrong_branch_count":wrong_branch_count,"branch_replanning_count":branch_replanning_count,"transport_replanning_count":transport.replanning_count,"replanning_count":branch_replanning_count+transport.replanning_count,"visited_zones":visited_zones.duplicate(),"completed_visits":completed_visits.duplicate()}

func track_journey_progress() -> void:
	for target: String in task_config.required_visits:
		if target not in completed_visits and player.position.distance_to(Layout.position_of(records[target])) <= 3.3:
			completed_visits.append(target)
			record_event("JOURNEY_WAYPOINT_REACHED",{"id":target})
			ui.toast("已到湖畔观景处。返回岔路后，沿下园支路前往交流会。")
	# Count a detour only when physically reaching an alternative branch landmark.
	# Choice is allowed; this metric does not prescribe or expose a correct route.
	for target: String in ["LingCollege_Approach","OtherBranch_End"]:
		if active_detour.is_empty() and player.position.distance_to(Layout.position_of(records[target])) <= 3.3:
			active_detour = target
			wrong_branch_count += 1
			record_event("JOURNEY_DESTINATION_MISMATCH",{"arrived":target,"destination":task_config.event.location})
			ui.toast("这里是%s。交流会在下园活动广场，可以原路返回岔路。" % records[target].name_zh)
	if not active_detour.is_empty() and (player.position.distance_to(Junction.point("FirstJunction")) <= 4 or player.position.distance_to(Junction.point("CollegeBranch_Fork")) <= 4):
		branch_replanning_count += 1
		record_event("JOURNEY_REPLAN",{"from":active_detour,"at":"FirstJunction" if player.position.distance_to(Junction.point("FirstJunction")) <= 4 else "CollegeBranch_Fork","destination":task_config.event.location})
		active_detour = ""

func zone_definitions() -> Array:
	var result := Zones.definitions()
	if full_journey:
		for zone: Dictionary in result:
			if zone.id in ["ZONE_UPPER_CAMPUS","ZONE_LOWER_CAMPUS"]:
				zone.active = true
				zone.confidence = "inferred"
				zone.name_zh = "上园出发广场" if zone.id == "ZONE_UPPER_CAMPUS" else "下园活动广场"
	return result
