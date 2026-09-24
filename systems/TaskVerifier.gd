extends RefCounted
## Pure evaluation: depends only on an explicit task and state snapshot.
static func verify(task: Dictionary, state: Dictionary, events: Array = []) -> Dictionary:
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
	for condition: Dictionary in task.get("temporal_conditions", []):
		var passed := verify_sequence(condition, events)
		conditions[condition.id] = passed
		details.append({"key":condition.id, "label":condition.label, "passed":passed})
		success = success and passed
	return {"task_id": task.get("id", ""), "success": success, "conditions": conditions, "details": details}

# Ordered, first-occurrence milestones prevent repairing a violated "before"
# constraint by repeating the same action later. Evidence comes from EventBus,
# not model claims, prompts or agent action names.
static func verify_sequence(condition: Dictionary, events: Array) -> bool:
	var last_index := -1
	for event_type: String in condition.get("events", []):
		var found := -1
		for index in events.size():
			if events[index].get("event") == event_type:
				found = index
				break
		if found <= last_index:
			return false
		last_index = found
	if last_index < 0:
		return false
	if condition.get("phone_closed_at_end", false):
		return events[last_index].get("data", {}).get("phone_open", true) == false
	return true
