extends RefCounted
signal diagnostic(event_type: String, data: Dictionary)
const PROMPT_VERSION := "campus_prompt_v1"
const SYSTEM_PROMPT := "你操作一个有时间限制的校园环境，目标是完成任务。只能选择 available_actions 中的完整动作对象，不能执行代码或虚构动作成功。世界在动作执行时真实推进，走路看手机会减速，NPC 会观察玩家；模型等待时间不计入校园时间。每一步必须依据当前 observation，不要假设上一动作已成功。地点：start_plaza 是入口，main_walkway 是老师前方的连廊，photo_spot 是合影花园，high_table 是晚宴门口。move_to 使用真实步行；talk_to 后依据新的可用动作回应；到门口需交谈并确认进入。wait 等待五秒。只按本次 output_contract 返回 JSON，不要输出代码、Markdown、解释或详细内部推理。简短计划只写可观察的行动步骤。"
const ACTION_TYPES := ["move_to", "talk_to", "open_phone", "close_phone", "reply_to_friend", "accept_photo_request", "decline_photo_request", "continue_dialogue", "enter_high_table", "wait"]
var provider: Node
var condition := "Reactive"
var max_attempts := 2
var history_limit := 10
var history: Array = []
var initial_plan: Array = []
var stats: Dictionary = {}

func reset_episode() -> void:
	history.clear()
	initial_plan.clear()
	stats = {"model_calls":0, "action_calls":0, "invalid_actions":0, "parse_errors":0, "provider_errors":0, "input_tokens":0, "output_tokens":0, "usage_reported_calls":0, "latency":0.0}

func context_for(observation: Dictionary, available: Array, kind: String = "action", retry_code: String = "") -> Dictionary:
	var current := observation.duplicate(true)
	# The environment's cached event list would otherwise leak trajectory into
	# Reactive. All three receive the exact same current-state projection.
	current.erase("recent_events")
	var payload := {"kind":kind, "task_instruction":current.current_task.description, "observation":current, "available_actions":available.duplicate(true)}
	if condition != "Reactive":
		payload.history = history.slice(maxi(0, history.size() - history_limit)).duplicate(true)
	if condition == "PlanHistory" and kind == "action":
		payload.plan = initial_plan.duplicate()
	payload.output_contract = {"format":"JSON object only", "keys":["type", "target (only if present in chosen available action)"], "rule":"Return exactly one member of available_actions; no additional keys."} if kind == "action" else {"format":"JSON object", "keys":["plan"], "rule":"plan is 1-5 short Simplified Chinese observable action steps, each at most 80 characters. No reasoning or rationale."}
	if not retry_code.is_empty():
		payload.previous_response_error = retry_code
	return {"system_prompt":SYSTEM_PROMPT, "payload":payload}

func prepare(observation: Dictionary, available: Array) -> Dictionary:
	if condition != "PlanHistory":
		return {"ok":true, "attempts":[]}
	var response := await _generate(observation, available, "plan")
	if response.ok:
		initial_plan = response.value.plan
	return response

func choose(observation: Dictionary, available: Array) -> Dictionary:
	return await _generate(observation, available, "action")

func remember(action: Dictionary, transition: Dictionary) -> void:
	history.append({"action":action.duplicate(true), "events":transition.events.duplicate(true), "valid":transition.valid, "done":transition.done})
	if history.size() > history_limit:
		history.pop_front()

func _generate(observation: Dictionary, available: Array, kind: String) -> Dictionary:
	var receipts: Array = []
	var retry_code := ""
	for attempt in max_attempts:
		var context := context_for(observation, available, kind, retry_code)
		var response: Dictionary = await provider.generate_plan(context) if kind == "plan" else await provider.generate_action(context)
		stats.model_calls += 1
		if kind == "action":
			stats.action_calls += 1
		stats.latency += float(response.get("latency", 0.0))
		var usage: Dictionary = response.get("usage", {})
		if usage.has("prompt_tokens") and usage.has("completion_tokens"):
			stats.usage_reported_calls += 1
			stats.input_tokens += usage.prompt_tokens
			stats.output_tokens += usage.completion_tokens
		var receipt := {"attempt":attempt + 1, "kind":kind, "latency":response.get("latency", 0.0), "usage":usage.duplicate(), "error":""}
		var checked := {"ok":false, "error":"provider_failure", "category":"LLM_PROVIDER_ERROR"}
		if response.get("ok", false):
			checked = validate_content(response.get("content", ""), available, kind)
		else:
			checked.error = response.get("error", "provider_failure")
		if checked.ok:
			receipts.append(receipt)
			return {"ok":true, "value":checked.value, "attempts":receipts, "latency":_latency(receipts)}
		retry_code = checked.error
		receipt.error = retry_code
		receipts.append(receipt)
		match checked.category:
			"LLM_PARSE_ERROR": stats.parse_errors += 1
			"LLM_INVALID_ACTION": stats.invalid_actions += 1
			_: stats.provider_errors += 1
		diagnostic.emit(checked.category, {"attempt":attempt + 1, "kind":kind, "reason":retry_code})
	return {"ok":false, "error":retry_code, "attempts":receipts, "latency":_latency(receipts)}

static func _latency(receipts: Array) -> float:
	var total := 0.0
	for receipt in receipts:
		total += receipt.latency
	return total

static func validate_content(content: Variant, available: Array, kind: String = "action") -> Dictionary:
	if not content is String or content.strip_edges().is_empty() or content.length() > 8192:
		return {"ok":false, "error":"empty_or_oversized_output", "category":"LLM_PARSE_ERROR"}
	var json := JSON.new()
	if json.parse(content) != OK:
		return {"ok":false, "error":"invalid_json", "category":"LLM_PARSE_ERROR"}
	var value: Variant = json.data
	if kind == "plan":
		if not value is Dictionary or value.size() != 1 or not value.get("plan") is Array or value.plan.is_empty() or value.plan.size() > 5:
			return {"ok":false, "error":"invalid_plan_schema", "category":"LLM_PARSE_ERROR"}
		for line in value.plan:
			if not line is String or line.strip_edges().is_empty() or line.length() > 80:
				return {"ok":false, "error":"invalid_plan_schema", "category":"LLM_PARSE_ERROR"}
		return {"ok":true, "value":value}
	if not value is Dictionary or value.get("type") not in ACTION_TYPES:
		return {"ok":false, "error":"unknown_action", "category":"LLM_INVALID_ACTION"}
	var targeted: bool = value.type in ["move_to", "talk_to"]
	if value.size() != (2 if targeted else 1) or (targeted and not value.get("target") is String):
		return {"ok":false, "error":"invalid_action_schema", "category":"LLM_INVALID_ACTION"}
	if value not in available:
		return {"ok":false, "error":"unavailable_action", "category":"LLM_INVALID_ACTION"}
	return {"ok":true, "value":value}
