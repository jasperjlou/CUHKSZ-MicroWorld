extends RefCounted
const Layout := preload("res://world/FairyLakeLayout.gd")
var world: Node3D
var active := false

func _init(owner_world: Node3D) -> void:
	world = owner_world

func observe() -> Dictionary:
	var visible: Array = []
	for id: String in world.records:
		var record: Dictionary = world.records[id]
		if id == "FairyLake" or world.player.position.distance_to(Layout.position_of(record)) <= 24:
			visible.append(record.duplicate(true))
	var destinations: Array[String] = []
	for id: String in world.records:
		if world.records[id].destination and world.records[id].active:
			destinations.append(id)
	var p: Vector3 = world.player.position
	var observation := {"schema_version":"lake-4","region":"fairy_lake_slice","position":[p.x,p.y,p.z],"objects":visible,"known_landmarks":world.seen.duplicate(),"destinations":destinations,"finished":world.finished,"geometry_evidence":"inferred","global_connections_verified":false,"actions":["navigate","inspect","wait","board","continue_walking"]}
	var event: Dictionary = world.current_event()
	observation.merge({"current_time":WorldTime.current_time,"current_time_text":GameState.format_time(WorldTime.current_time,true),"event_start_time":event.start_time,"time_remaining":event.time_remaining,"event_status":event.status,"destination":event.destination,"destination_confidence":event.confidence,"current_location":GameState.get_value("current_location"),"event":event,"time_scale":WorldTime.time_scale,"task_result":world.result.duplicate(true)})
	observation.merge(world.transport.observe())
	observation.location = world.location_observation()
	observation.zones = world.zone_definitions()
	observation.frontier = world.Survey.observe()
	observation.ground_context = world.Ground.observe(world.player.position)
	observation.junction = world.Junction.definition().duplicate(true)
	if world.full_journey:
		observation.schema_version = "journey-1"
		observation.region = "cross_campus_journey"
		observation.destination_confidence = world.records[observation.destination].confidence
		observation.current_zone = observation.location.zone
		observation.nearest_landmark = observation.location.nearest_landmark
		observation.junction_branches = observation.junction.branches.duplicate(true)
		for branch: Dictionary in observation.junction_branches:
			if branch.id in ["upper","lower"]:
				branch.target = "UpperCampus_Start" if branch.id == "upper" else "LowerCampus_Event_Area"
				branch.destination_reached = true
				branch.destination_scope = "bounded_authored_slice_not_surveyed_campus"
			elif branch.id == "ling":
				branch.destination_reached = true
				branch.destination_scope = "gate_landmark_only_no_interior"
		observation.junction.base_version = observation.junction.version
		observation.junction.version = world.task_config.version
		observation.junction.branches = observation.junction_branches.duplicate(true)
		observation.journey = world.journey_metrics()
		observation.journey.start = world.task_config.start
		observation.journey.required_visits = world.task_config.required_visits.duplicate()
		observation.replanning_count = observation.journey.replanning_count
	return observation

func step(action: Dictionary) -> Dictionary:
	if not is_instance_valid(world):
		return {"ok":false,"reason":"world_replaced"}
	var kind := str(action.get("type",""))
	var target := str(action.get("target",""))
	var may_wait_in_transport: bool = kind == "wait" and world.transport.riding and not GameState.get_flag("modal_open") and not GameState.get_flag("paused") and not world.finished
	if active or (not GameState.can_move() and not may_wait_in_transport):
		return world.reject_action("not_ready",action)
	if kind == "board":
		var boarded: Dictionary = world.transport.board(str(action.get("shuttle_id",target)),"agent",str(action.get("reason","")))
		boarded["observation"] = observe()
		return boarded
	if kind == "continue_walking":
		world.transport.choice("walk",str(action.get("reason","")),"agent")
		return {"ok":true,"observation":observe()}
	if kind == "wait":
		var duration: Variant = action.get("duration",null)
		if not (duration is int or duration is float) or not is_finite(float(duration)) or float(duration) <= 0 or float(duration) > 1800:
			return world.reject_action("invalid_duration",action)
		if world.transport.nearby():
			world.transport.choice("wait",str(action.get("reason","")),"agent")
		return await _wait(float(duration),action)
	if not world.records.has(target):
		return world.reject_action("unknown_target",action)
	var record: Dictionary = world.records[target]
	if kind == "inspect":
		if not record.interactable or world.player.position.distance_to(Layout.position_of(record)) > 3.3:
			return world.reject_action("not_interactable_or_out_of_range",action)
		world.record_event("AGENT_ACTION",action)
		return {"ok":world.interact(target),"observation":observe()}
	if kind != "navigate" or not record.destination or not record.walkable or not record.active:
		return world.reject_action("not_walkable_destination",action)
	world.transport.choice("walk",str(action.get("reason","")),"agent")
	world.ui.close_choice()
	world.record_event("AGENT_ACTION",action)
	active = true
	world.player.agent_controlled = true
	var route: Array[Vector3] = world.path_graph.route(world.player.position,Layout.position_of(record))
	var completed := true
	for waypoint: Vector3 in route:
		var remaining := 1800
		while Vector2(world.player.position.x-waypoint.x,world.player.position.z-waypoint.z).length() > 0.25:
			if remaining <= 0 or world.finished:
				completed = false
				break
			# Bound even a paused/stuck caller; the player still obeys modal movement locks.
			remaining -= 1
			world.player.navigation_direction = Vector2(waypoint.x-world.player.position.x,waypoint.z-world.player.position.z).normalized()
			await world.get_tree().physics_frame
			if not is_instance_valid(world):
				active = false
				return {"ok":false,"reason":"world_replaced"}
		if not completed:
			break
	world.player.navigation_direction = Vector2.ZERO
	for _i in range(5):
		await world.get_tree().physics_frame
		if not is_instance_valid(world):
			active = false
			return {"ok":false,"reason":"world_replaced"}
	world.player.agent_controlled = false
	active = false
	world.record_event("NAVIGATION_FINISHED",{"target":target,"ok":completed})
	return {"ok":completed,"observation":observe()}

func _wait(duration: float, action: Dictionary) -> Dictionary:
	active = true
	world.record_event("AGENT_ACTION",action)
	world.player.agent_controlled = true
	world.player.navigation_direction = Vector2.ZERO
	var deadline := WorldTime.current_time+duration
	var budget := int(ceil(duration/WorldTime.time_scale*120))+1800
	while WorldTime.current_time < deadline and budget > 0 and not world.finished:
		budget -= 1
		await world.get_tree().physics_frame
		if not is_instance_valid(world):
			active = false
			return {"ok":false,"reason":"world_replaced"}
	world.player.agent_controlled = false
	active = false
	var completed := WorldTime.current_time >= deadline
	world.record_event("WAIT_FINISHED",{"duration":duration,"ok":completed})
	return {"ok":completed,"observation":observe()}

func _nearest_index(p: Vector3) -> int:
	var index := 0
	var distance := INF
	for i in world.route_points.size():
		var d := p.distance_to(world.route_points[i])
		if d < distance:
			distance = d
			index = i
	return index
