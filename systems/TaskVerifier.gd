extends RefCounted
## Pure evaluation: depends only on an explicit task and state snapshot.
static func verify(task: Dictionary, state: Dictionary) -> Dictionary:
	var conditions: Dictionary = {}
	var details: Array[Dictionary] = []
	var requirements: Array = task.get("conditions", [])
	var success := not requirements.is_empty()
	for condition: Dictionary in requirements:
		var key: String = condition["key"]
		var passed: bool = state.has(key) and state[key] == condition["expected"]
		# "On time" must describe a real arrival, never an isolated flag.
		if key == "arrived_on_time":
			var arrival := float(state.get("arrival_time", -1.0))
			passed = passed and bool(state.get("reached_high_table", false)) and arrival >= 0.0 and arrival < 19.0 * 3600.0
		conditions[key] = passed
		details.append({"key": key, "label": condition["label"], "passed": passed})
		success = success and passed
	return {"task_id": task.get("id", ""), "success": success, "conditions": conditions, "details": details}
