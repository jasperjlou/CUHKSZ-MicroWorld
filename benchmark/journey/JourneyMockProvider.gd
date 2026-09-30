extends "res://benchmark/providers/Provider.gd"
## Deterministic pipeline fixture, no world or private task access. Not an LLM finding.
func complete(context: Dictionary) -> Dictionary:
	var payload: Dictionary = context.payload
	if payload.kind == "plan":
		return _reply({"plan":["检查任务地点、时间和交通状态。","完成必经点后到目的地签到。"]})
	var o: Dictionary = payload.observation
	var legal: Array = payload.available_actions
	if o.in_transport:
		return _reply({"type":"wait","duration":120})
	var target: String = o.destination
	for visit: String in o.current_task.required_visits:
		if visit not in o.completed_visits:
			target = visit
			break
	for branch: Dictionary in o.junction_branches:
		if branch.id in ["ling","other"] and branch.target in o.nearby and branch.target != target:
			return _reply({"type":"navigate","target":"FirstJunction"})
	if target in o.nearby:
		return _reply({"type":"inspect","target":target})
	if target == o.destination and "shuttle" in o.current_task.allowed_transport and o.shuttle_stop.nearby:
		if o.shuttle.estimated_total_time != null and float(o.shuttle.estimated_total_time) < float(o.walking.estimated_time):
			var board := {"type":"board","shuttle_id":o.shuttle.id}
			return _reply(board if board in legal else {"type":"wait","duration":30})
		if o.waiting:
			return _reply({"type":"continue_walking"})
	return _reply({"type":"navigate","target":target})

func _reply(value: Dictionary) -> Dictionary:
	return {"ok":true,"content":JSON.stringify(value),"usage":{},"latency":0.0}
