extends RefCounted
# Reuses RC1 provider contract, but supplies the V6 action schema explicitly.
# No API keys or external providers enabled by this product.
var provider: Node
func context_for(observation: Dictionary,available: Array) -> Dictionary:
	return {"system_prompt":"你在港中深校园中行动。只能返回可用动作中的一个完整 JSON 对象，不要输出解释或内部推理。步行使用真实物理，等待模型时校园时间暂停。","payload":{"observation":observation.duplicate(true),"available_actions":available.duplicate(true),"output_contract":{"format":"JSON","rule":"exact member of available_actions"}}}
static func validate(content: Variant,available: Array) -> Dictionary:
	if not content is String or content.length()>8192:return {"ok":false,"error":"INVALID_SCHEMA"}
	var parsed: Variant=JSON.parse_string(content)
	if not parsed is Dictionary or parsed not in available:return {"ok":false,"error":"UNAVAILABLE_ACTION"}
	return {"ok":true,"value":parsed}
func choose(observation: Dictionary,available: Array) -> Dictionary:
	var response: Dictionary=await provider.generate_action(context_for(observation,available))
	return validate(response.get("content",""),available) if response.get("ok",false) else {"ok":false,"error":"PROVIDER_ERROR"}
