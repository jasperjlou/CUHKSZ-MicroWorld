extends Node3D
## Transport adapter over the existing lake navigation; no claim of a surveyed bus route.
const Layout := preload("res://world/FairyLakeLayout.gd")
const Kit := preload("res://world/MeshKit.gd")
const Shuttle := preload("res://systems/ShuttleSystem.gd")
const STOP_ID := "Prototype_Shuttle_Stop"
var world: Node3D
var shuttle := Shuttle.new()
var config: Dictionary
var scenario_id := ""
var waiting := false
var riding := false
var waiting_time := 0.0
var boarding_time: Variant = null
var ride_time := 0.0
var replanning_count := 0
var shuttle_used := false
var choice_mode := ""
var bus: Node3D
var stop_label: Label3D

func _ready() -> void:
	config = JSON.parse_string(FileAccess.get_file_as_string("res://tasks/lake_transport.json"))
	if world.full_journey:
		config.scenarios = world.task_config.transport_scenarios.duplicate(true)
		config.shuttle.route = [STOP_ID,world.task_config.event.location]
	scenario_id = str(Engine.get_meta("lake_transport_scenario",config.default_scenario))
	if not config.scenarios.has(scenario_id):
		scenario_id = config.default_scenario
	configure(scenario_id)
	shuttle.state_changed.connect(_on_state)
	WorldTime.advanced.connect(_on_time)
	var stop := Layout.object(STOP_ID,"原型接驳候车点","Prototype_Shuttle_Stop",Layout.POINTS[0],true,true,false,true,true,["prototype","transport_choice","location_unverified"],"placeholder")
	stop.zone = "ZONE_SHUTTLE_STOP"
	world.records[STOP_ID] = stop
	var marker := Node3D.new()
	marker.name = STOP_ID+"__placeholder"
	marker.position = Layout.POINTS[0]
	marker.set_meta("semantic",stop.duplicate(true))
	marker.add_to_group("lake_semantics")
	world.builder.add_child(marker)
	world.builder.semantic_nodes[STOP_ID] = marker
	_build_visual()

func configure(id: String) -> void:
	if GameState.get_flag("started") or not config.scenarios.has(id):
		return
	scenario_id = id
	Engine.set_meta("lake_transport_scenario",id)
	var definition: Dictionary = config.shuttle.duplicate(true)
	definition.merge(config.scenarios[id],true)
	shuttle.reset(definition,WorldTime.initial_time)

func nearby() -> bool:
	return not riding and world.player.position.distance_to(Layout.POINTS[0]) <= 3.3

func walking_eta() -> float:
	# Same speed/time assumptions, using the world graph for newly branched geometry.
	var origin: Vector3 = world.player.position
	var distance := 0.0
	if world.full_journey:
		for visit: String in world.task_config.required_visits:
			if visit not in world.completed_visits:
				var waypoint := Layout.position_of(world.records[visit])
				distance += world.path_graph.distance(origin,waypoint)
				origin = waypoint
	distance += world.path_graph.distance(origin,Layout.position_of(world.records[world.task_config.event.location]))
	return distance/world.player.WALK_SPEED*WorldTime.time_scale

func observe() -> Dictionary:
	var bus_state := shuttle.observe(WorldTime.current_time)
	bus_state.boardable = nearby() and shuttle.can_board() and not riding and not world.finished
	return {"walking":{"estimated_time":null if riding else walking_eta(),"available":not riding and not world.finished,"estimate_basis":"remaining_task_waypoints_at_normal_walk_speed" if world.full_journey else "remaining_world_graph_at_normal_walk_speed","includes_jog":false},"shuttle_stop":{"id":STOP_ID,"nearby":nearby(),"confidence":"placeholder"},"shuttle":bus_state,"waiting_time":waiting_time,"waiting":waiting,"in_transport":riding,"position_mode":"transport_anchor" if riding else "world","transport_available":bus_state.boardable,"replanning_count":replanning_count}

func choice(mode: String, reason: String = "", source: String = "human") -> void:
	if not GameState.get_flag("started") or world.finished or riding:
		return
	if mode == "wait" and not nearby():
		return
	if mode == "walk" and waiting:
		replanning_count += 1
		world.record_event("TRANSPORT_REPLAN",{"from":"wait","to":"walk","reason":reason,"source":source})
	waiting = mode == "wait"
	choice_mode = mode
	world.record_event("TRANSPORT_CHOICE",{"choice":mode,"reason":reason,"reason_source":"caller_supplied" if not reason.is_empty() else "unspecified","source":source,"observation":observe()})

func board(id: String, source: String = "human", reason: String = "") -> Dictionary:
	var action := {"type":"board","shuttle_id":id,"reason":reason}
	if world.finished or not GameState.can_move() or riding:
		return world.reject_action("not_ready",action)
	if id != str(shuttle.definition.id):
		return world.reject_action("unknown_shuttle",action)
	if not nearby():
		return world.reject_action("outside_boarding_zone",action)
	if not shuttle.can_board():
		return world.reject_action("shuttle_not_boarding_or_full",action)
	choice("shuttle",reason,source)
	world._track_movement()
	shuttle.board(WorldTime.current_time)
	shuttle_used = true
	riding = true
	waiting = false
	boarding_time = WorldTime.current_time
	world.player.navigation_direction = Vector2.ZERO
	world.player.velocity = Vector3.ZERO
	world.player.set_physics_process(false)
	world.player.model.hide()
	GameState.set_flag("busy",true)
	GameState.set_value("current_location","transport:"+id)
	world.ui.close_choice()
	world.ui.notice_remaining = 0
	world.record_event("TRANSPORT_BOARDED",{"shuttle_id":id,"transport_abstraction":true,"boarding_time":boarding_time})
	return {"ok":true,"in_transport":true}

func _on_time(previous: float, now: float) -> void:
	if world.finished:
		return
	if waiting:
		waiting_time += now-previous
	if riding:
		ride_time += maxf(0,minf(now,shuttle.destination_arrival)-maxf(previous,shuttle.departure_time))
	shuttle.update(now)
	if riding and shuttle.state == "arrived":
		_arrive()

func _on_state(before: String, after: String) -> void:
	if not GameState.get_flag("started"):
		return
	world.record_event("SHUTTLE_STATE_CHANGED",{"before":before,"after":after,"shuttle_id":shuttle.definition.id})
	if after == "boarding" and nearby():
		world.ui.toast("接驳车到了。走近候车牌，按 [E] 查看上车选项。")

func _arrive() -> void:
	var origin: Vector3 = world.player.position
	world.player.position = Layout.position_of(world.records[world.task_config.event.location])+Vector3.UP*0.1
	world.player.velocity = Vector3.ZERO
	world.previous = world.player.position # Transport displacement is NOT walking path length.
	world.last_safe = world.player.position
	world.player.agent_controlled = false
	world.player.model.show()
	world.player.set_physics_process(true)
	world.player.update_camera(1.0,true)
	riding = false
	GameState.set_flag("busy",false)
	GameState.set_value("current_location",world.task_config.event.location)
	world.record_event("TRANSPORT_ARRIVED",{"transport_abstraction":true,"from":[origin.x,origin.y,origin.z],"to":[world.player.position.x,world.player.position.y,world.player.position.z],"ride_time":ride_time})
	world.ui.toast("已到下园活动广场。按 [E] 签到。" if world.full_journey else "已到下园方向占位出口。按 [E] 签到，查看本局结果。")

func metrics() -> Dictionary:
	return {"transport_mode":"shuttle" if shuttle_used else "walk","waiting_time":waiting_time,"shuttle_used":shuttle_used,"scheduled_arrival":shuttle.scheduled_arrival,"actual_arrival":shuttle.actual_arrival,"delay":shuttle.delay,"boarding_time":boarding_time,"ride_time":ride_time,"replanning_count":replanning_count,"scenario_id":scenario_id,"scenario_seed":shuttle.definition.scenario_seed,"information_mode":shuttle.definition.information_mode,"transport_abstraction":true,"transport_confidence":"placeholder"}

func _process(_delta: float) -> void:
	if waiting and not nearby() and not riding:
		choice("walk","离开候车范围","movement")
	elif choice_mode.is_empty() and GameState.can_move() and world.player.moving:
		choice("walk","直接沿步道移动","movement")
	if not is_instance_valid(bus):
		return
	var state: String = shuttle.state
	bus.visible = state in ["approaching","boarding","in_transit"] and WorldTime.current_time < shuttle.departure_time+30
	var z_offset := 0.0
	if state == "approaching":
		z_offset = -12*clampf((shuttle.actual_arrival-WorldTime.current_time)/30,0,1)
	elif state == "in_transit":
		z_offset = -12*clampf((WorldTime.current_time-shuttle.departure_time)/30,0,1)
	bus.position = Layout.POINTS[0]+Layout.right_at(0)*4.8+Vector3(0,0,z_offset)

func _build_visual() -> void:
	var base: Vector3 = Layout.POINTS[0]+Layout.right_at(0)*2.5
	Kit.cylinder(self,base+Vector3.UP,0.07,2,Color("455c54"))
	Kit.box(self,base+Vector3.UP*2,Vector3(1.2,0.8,0.12),Color("366e62"))
	stop_label = Kit.label(self,"接驳候车\n原型站点",base+Vector3(0,2.1,0.15),24)
	stop_label.pixel_size = 0.014
	bus = Node3D.new()
	add_child(bus)
	bus.set_meta("prototype_visual",true)
	Kit.box(bus,Vector3(0,1.15,0),Vector3(1.9,1.65,3.6),Color("d7dfc7"))
	Kit.box(bus,Vector3(0,1.4,-1.82),Vector3(1.6,0.7,0.05),Color("456d74"))
	Kit.box(bus,Vector3(0,0.68,0),Vector3(1.94,0.32,3.65),Color("438375"))
	for x: float in [-0.97,0.97]:
		for z: float in [-1.05,1.05]:
			var wheel := Kit.cylinder(bus,Vector3(x,0.42,z),0.36,0.17,Color("394443"))
			wheel.rotation.z = PI/2
	Kit.label(bus,"原型接驳",Vector3(0,2.25,0),22)
