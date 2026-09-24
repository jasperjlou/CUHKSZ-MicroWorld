extends RefCounted
static func aggregate(rows: Array) -> Dictionary:
	var success := 0
	var steps := 0
	var invalid := 0
	var parse_errors := 0
	var warned := 0
	var on_time := 0
	var action_calls := 0
	var model_calls := 0
	var duration := 0.0
	for row in rows:
		success += int(row.success)
		steps += row.steps
		invalid += row.invalid_actions
		parse_errors += row.parse_errors
		warned += int(row.teacher_warned)
		on_time += int(row.arrived_on_time)
		action_calls += row.action_calls
		model_calls += row.model_calls
		duration += row.completion_time
	var n := rows.size()
	return {"episodes":n, "successes":success, "success_rate":float(success)/maxi(n, 1), "average_steps":float(steps)/maxi(n, 1), "invalid_action_rate":float(invalid)/maxi(action_calls, 1), "parse_error_rate":float(parse_errors)/maxi(model_calls, 1), "teacher_warning_rate":float(warned)/maxi(n, 1), "on_time_rate":float(on_time)/maxi(n, 1), "average_completion_time":duration/maxi(n, 1), "action_calls":action_calls, "model_calls":model_calls}

static func summarize(rows: Array) -> Dictionary:
	var by_condition: Dictionary = {}
	var by_task: Dictionary = {}
	var by_pair: Dictionary = {}
	for row in rows:
		if not by_condition.has(row.condition): by_condition[row.condition] = []
		if not by_task.has(row.task_id): by_task[row.task_id] = []
		var pair: String = row.condition + "/" + row.task_id
		if not by_pair.has(pair): by_pair[pair] = []
		by_condition[row.condition].append(row)
		by_task[row.task_id].append(row)
		by_pair[pair].append(row)
	for group in [by_condition, by_task, by_pair]:
		for key in group:
			group[key] = aggregate(group[key])
	return {"overall":aggregate(rows), "by_condition":by_condition, "by_task":by_task, "by_condition_task":by_pair}

static func csv(rows: Array) -> String:
	if rows.is_empty(): return ""
	var keys: Array = rows[0].keys()
	var lines: Array[String] = []
	lines.append(",".join(keys))
	for row in rows:
		var fields: Array[String] = []
		for key in keys:
			var value := str(row.get(key, "")).replace('"', '""')
			fields.append('"' + value + '"')
		lines.append(",".join(fields))
	return "\n".join(lines) + "\n"
