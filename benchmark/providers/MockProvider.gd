extends "res://benchmark/providers/Provider.gd"
# SCRIPTED TEST FIXTURE ONLY. Task-specific witnesses test reachability and
# pipeline plumbing; they are not model behavior or a competitive baseline.
var witness_actions: Array = []
var cursor := 0
var faults: Array = []
var calls := 0

func begin_episode(task_id: String, _seed_value: int) -> void:
	cursor = 0
	calls = 0
	witness_actions = []
	if task_id == "once_is_enough":
		witness_actions = [_a("open_phone"), _a("move_to", "main_walkway"), _a("wait"), _a("close_phone")]
	elif task_id in ["read_then_pass", "reply_arrive", "all_on_time", "reply_before_photo", "careful_student", "helpful_student"]:
		witness_actions.append(_a("open_phone"))
		if task_id != "read_then_pass":
			witness_actions.append(_a("reply_to_friend"))
		witness_actions.append(_a("close_phone"))
	if task_id in ["helpful_student", "careful_student", "all_on_time", "silent_helper", "reply_before_photo", "polite_decline"]:
		witness_actions.append_array([_a("move_to", "photo_spot"), _a("talk_to", "photo_student"), _a("decline_photo_request" if task_id == "polite_decline" else "accept_photo_request")])
	witness_actions.append_array([_a("move_to", "high_table"), _a("talk_to", "friend_01"), _a("enter_high_table")])

func _a(kind: String, target: String = "") -> Dictionary:
	var action := {"type":kind}
	if not target.is_empty():
		action.target = target
	return action

func complete(context: Dictionary) -> Dictionary:
	calls += 1
	if not faults.is_empty():
		var fault: String = faults.pop_front()
		match fault:
			"timeout", "provider_failure", "empty_response":
				return {"ok":false, "error":fault, "latency":0.01, "usage":{}}
			"malformed":
				return {"ok":true, "content":"{broken", "latency":0.01, "usage":{}}
			"unknown":
				return {"ok":true, "content":'{"type":"teleport"}', "latency":0.01, "usage":{}}
			"unavailable":
				return {"ok":true, "content":'{"type":"accept_photo_request"}', "latency":0.01, "usage":{}}
			"empty":
				return {"ok":true, "content":"", "latency":0.01, "usage":{}}
	if context.payload.kind == "plan":
		return {"ok":true, "content":JSON.stringify({"plan":["按任务顺序处理手机消息和合影请求。", "留意提醒和时间，到晚宴门口确认进入。"]}), "latency":0.0, "usage":{}}
	var action: Dictionary = witness_actions[cursor] if cursor < witness_actions.size() else {"type":"wait"}
	if action in context.payload.available_actions:
		cursor += 1
	return {"ok":true, "content":JSON.stringify(action), "latency":0.0, "usage":{}}
