extends "res://benchmark/LLMAgent.gd"
## Reuses provider retries/usage/latency; only the journey prompt and action contract differ.
const JOURNEY_PROMPT := "你在校园评测环境中完成任务。只返回 available_actions 中的一个完整 JSON 动作，不添加字段。navigate 通过已有语义导航和物理碰撞执行步行，不能传送；到达任务地点后 inspect 签到。观察当前时间、任务允许的到达时段、必经点和接驳信息后决策。地点编号和岔路语义是公开信息，没有隐藏正确路线。等待与步行推进游戏时间，模型思考期间世界暂停。wait 的 duration 是游戏秒。接驳是虚构的抽象乘车。每次重新查看动作结果，勿假定成功。计划仅写简短行动步骤，不输出内部推理。"

func context_for(observation: Dictionary, available: Array, kind: String = "action", retry_code: String = "") -> Dictionary:
	var context := super.context_for(observation,available,kind,retry_code)
	context.system_prompt = JOURNEY_PROMPT
	context.payload.output_contract = {"rule":"Return exactly one available_actions object, without additional keys."} if kind == "action" else {"rule":"Return {plan: [1-5 short Chinese action steps, each <=80 characters]}; no reasoning."}
	return context

func _validate(content: Variant, available: Array, kind: String) -> Dictionary:
	if kind == "plan":
		return validate_content(content,available,kind)
	if content is String and content.length() <= 8192:
		var json := JSON.new()
		if json.parse(content) == OK and json.data is Dictionary:
			var value: Dictionary = json.data
			for candidate: Dictionary in available:
				# JSON numbers are floats; compare fields, then return the canonical legal object.
				if candidate.size() == value.size() and candidate.keys().all(func(key): return value.has(key) and value[key] == candidate[key]):
					return {"ok":true,"value":candidate.duplicate(true)}
	return {"ok":false,"error":"invalid_or_unavailable_action","category":"LLM_INVALID_ACTION"}

func remember_step(observation: Dictionary, action: Dictionary, response: Dictionary) -> void:
	history.append({"observation":observation.duplicate(true),"action":action.duplicate(true),"result":response.duplicate(true)})
	while history.size() > history_limit:
		history.pop_front()
