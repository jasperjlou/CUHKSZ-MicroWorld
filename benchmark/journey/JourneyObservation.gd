extends RefCounted
## Explicit current-state projection. No verifier, future states, path graph or task setup.
static func observe(world: Node, task: Dictionary) -> Dictionary:
	var raw: Dictionary = world.environment_api.observe()
	var result: Dictionary = {}
	for key in ["position","objects","destinations","current_time","current_time_text","current_zone","nearest_landmark","destination","destination_confidence","time_remaining","event_start_time","event_status","shuttle","shuttle_stop","walking","in_transport","waiting","junction_branches"]:
		result[key] = raw[key]
	result.current_task = {"description":task.instruction,"destination":task.destination,"required_visits":task.required_visits.duplicate(),"allowed_transport":task.allowed_transport.duplicate()}
	result.completed_visits = world.completed_visits.duplicate()
	result.event_end_time = task.event_end
	result.nearby = []
	for record: Dictionary in raw.objects:
		if world.player.position.distance_to(world.Layout.position_of(record)) <= 3.3:
			result.nearby.append(record.id)
	return result.duplicate(true)

static func actions(world: Node, task: Dictionary) -> Array:
	var result: Array = []
	if world.finished:
		return result
	for duration in [30,120,600]:
		result.append({"type":"wait","duration":duration})
	if world.transport.riding:
		return result
	for id: String in world.records:
		var record: Dictionary = world.records[id]
		if "walk" in task.allowed_transport and record.destination and record.walkable and record.active:
			result.append({"type":"navigate","target":id})
		# Inspecting a stop opens a human modal; transport is exposed by board/wait instead.
		if record.interactable and id != world.transport.STOP_ID and world.player.position.distance_to(world.Layout.position_of(record)) <= 3.3:
			result.append({"type":"inspect","target":id})
	if world.transport.waiting and "walk" in task.allowed_transport:
		result.append({"type":"continue_walking"})
	if "shuttle" in task.allowed_transport and world.transport.nearby() and world.transport.shuttle.can_board():
		result.append({"type":"board","shuttle_id":world.transport.shuttle.definition.id})
	return result
