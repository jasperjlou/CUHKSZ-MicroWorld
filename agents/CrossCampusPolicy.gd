extends RefCounted
## Small deterministic baseline using only public observation. No privileged world access.
## AStar and physical movement remain the environment's existing navigation action.
func decide(observation: Dictionary) -> Dictionary:
	if observation.finished:
		return {}
	var target: String = observation.destination
	for visit: String in observation.journey.required_visits:
		if visit not in observation.journey.completed_visits:
			target = visit
			break
	var position: Array = observation.position
	# An alternative endpoint is publicly identifiable. Return to the junction
	# before choosing the next leg; this decision is separate from AStar execution.
	for branch: Dictionary in observation.junction_branches:
		if not branch.walkable or branch.target in [observation.journey.start,observation.destination]:
			continue
		for record: Dictionary in observation.objects:
			if record.id == branch.target:
				var p: Array = record.position
				if Vector3(position[0],position[1],position[2]).distance_to(Vector3(p[0],p[1],p[2])) <= 3.3:
					return {"type":"navigate","target":"FirstJunction","reason":"当前支路终点与任务地点不符，先返回岔路重新选择"}
	for record: Dictionary in observation.objects:
		if record.id == target:
			var p: Array = record.position
			if Vector3(position[0],position[1],position[2]).distance_to(Vector3(p[0],p[1],p[2])) <= 3.3:
				return {"type":"inspect","target":target,"reason":"已到达当前任务地点"}
	return {"type":"navigate","target":target,"reason":"依据任务地点与当前位置继续行程"}
