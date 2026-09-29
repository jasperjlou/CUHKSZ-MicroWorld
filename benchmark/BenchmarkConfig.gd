extends RefCounted
const VERSION := "cuhksz_microworld_v0.1"
const CONDITIONS := ["Reactive", "History", "PlanHistory"]
const CONDITION_NAMES := {"Reactive":"即时观察", "History":"观察与历史", "PlanHistory":"计划与历史"}
var provider := "mock"
var model := "scripted-fixture-v1"
var temperature := 0.0
var max_tokens := 512
var supports_seed := false
var json_mode := false
var token_parameter := "max_tokens"
var timeout_seconds := 30.0
var attempts := 2
var history_steps := 10
var episodes := 1
var max_steps := 40
var conditions: Array = CONDITIONS.duplicate()
var task_ids: Array = []
var seed_start := 1000
var error := ""

func _init() -> void:
	model = OS.get_environment("LLM_MODEL") if OS.has_environment("LLM_MODEL") else model
	supports_seed = OS.get_environment("LLM_SUPPORTS_SEED") == "1"
	json_mode = OS.get_environment("LLM_JSON_MODE") == "1"
	if OS.get_environment("LLM_TOKEN_PARAMETER") == "max_completion_tokens":
		token_parameter = "max_completion_tokens"
	if OS.has_environment("LLM_TEMPERATURE"):
		temperature = OS.get_environment("LLM_TEMPERATURE").to_float()
	for arg in OS.get_cmdline_user_args():
		var pair := arg.split("=", true, 1)
		if pair.size() != 2:
			continue
		match pair[0]:
			"--provider": provider = pair[1]
			"--model": model = pair[1]
			"--condition": conditions = CONDITIONS.duplicate() if pair[1] == "all" else [pair[1]]
			"--tasks": task_ids = Array(pair[1].split(",")) if pair[1] != "all" else []
			"--episodes": episodes = pair[1].to_int()
			"--max-steps": max_steps = pair[1].to_int()
			"--seed": seed_start = pair[1].to_int()
			"--max-tokens": max_tokens = pair[1].to_int()
			"--temperature": temperature = pair[1].to_float()
			"--timeout": timeout_seconds = pair[1].to_float()
	if provider == "mock":
		model = "scripted-fixture-v1"
		supports_seed = false

func validate(tasks: Array) -> String:
	if provider not in ["mock", "openai_compatible"]:
		return "未知服务类型"
	if not is_finite(temperature) or temperature < 0 or temperature > 2:
		return "温度参数应在零到二之间"
	if conditions.is_empty():
		return "至少选择一个上下文条件"
	if episodes < 1 or episodes > 100 or max_steps < 1 or max_steps > 100 or max_tokens < 64 or max_tokens > 4096 or timeout_seconds <= 0 or timeout_seconds > 120:
		return "评测参数超出支持范围"
	for condition in conditions:
		if condition not in CONDITIONS:
			return "未知上下文条件"
	for task in task_ids:
		if not tasks.any(func(t): return t.id == task):
			return "未知任务"
	if provider == "openai_compatible" and (OS.get_environment("LLM_BASE_URL").is_empty() or model.is_empty() or model == "scripted-fixture-v1"):
		return "尚未配置模型地址或模型名称；可选择模拟服务验证流程。"
	return ""

func metadata() -> Dictionary:
	return {"benchmark_version":VERSION, "provider":provider, "model":model, "temperature":temperature, "max_tokens":max_tokens, "token_parameter":token_parameter, "seed_supported":supports_seed, "json_mode":json_mode, "timeout_seconds":timeout_seconds, "max_attempts":attempts, "history_steps":history_steps, "max_steps":max_steps, "task_suite_version":"campus_tasks_v1", "environment_version":"v0.6-campus-identity", "clock_policy":"decision_gated", "is_mock":provider == "mock"}
