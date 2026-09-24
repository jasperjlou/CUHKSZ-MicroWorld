extends "res://benchmark/providers/Provider.gd"
var config: RefCounted
var episode_seed := 0

func begin_episode(_task_id: String, seed_value: int) -> void:
	episode_seed = seed_value

func complete(context: Dictionary) -> Dictionary:
	var base_url := OS.get_environment("LLM_BASE_URL").trim_suffix("/")
	# Credentials never enter context, metadata, logs or error strings. Disable
	# redirects to avoid forwarding bearer authorization to another host.
	if not (base_url.begins_with("https://") or base_url.begins_with("http://")) or "@" in base_url or "?" in base_url or "#" in base_url:
		return {"ok":false, "error":"invalid_endpoint", "latency":0.0, "usage":{}}
	if base_url.begins_with("http://") and not (base_url.begins_with("http://127.0.0.1:") or base_url.begins_with("http://localhost:") or base_url.begins_with("http://[::1]:")):
		return {"ok":false, "error":"https_required", "latency":0.0, "usage":{}}
	var url := base_url if base_url.ends_with("/chat/completions") else base_url + "/chat/completions"
	var body := {"model":config.model, "temperature":config.temperature, "messages":[{"role":"system", "content":context.system_prompt}, {"role":"user", "content":JSON.stringify(context.payload)}], "stream":false}
	body[config.token_parameter] = config.max_tokens
	if config.supports_seed:
		body.seed = episode_seed
	if config.json_mode:
		body.response_format = {"type":"json_object"}
	var headers := PackedStringArray(["Content-Type: application/json"])
	var key := OS.get_environment("LLM_API_KEY")
	if not key.is_empty():
		headers.append("Authorization: Bearer " + key)
	var http := HTTPRequest.new()
	# Godot Timer advances with --fixed-fps. Network deadlines must use
	# monotonic wall time, independently of accelerated simulation.
	http.timeout = 0.0
	http.max_redirects = 0
	http.body_size_limit = 1048576
	add_child(http)
	var replies: Array = []
	http.request_completed.connect(func(result: int, code: int, response_headers: PackedStringArray, response_body: PackedByteArray): replies.append([result, code, response_headers, response_body]), CONNECT_ONE_SHOT)
	var started := Time.get_ticks_msec()
	var request_error := http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if request_error != OK:
		http.queue_free()
		return {"ok":false, "error":"request_failed", "latency":0.0, "usage":{}}
	var prior_max_fps := Engine.max_fps
	if prior_max_fps == 0 or prior_max_fps > 120:
		Engine.max_fps = 120
	while replies.is_empty():
		if Time.get_ticks_msec() - started >= config.timeout_seconds * 1000.0:
			http.cancel_request()
			http.queue_free()
			Engine.max_fps = prior_max_fps
			return {"ok":false, "error":"timeout", "latency":(Time.get_ticks_msec() - started) / 1000.0, "usage":{}}
		await get_tree().process_frame
		if DisplayServer.get_name() == "headless":
			OS.delay_msec(1) # Yield CPU while polling real I/O, never advance world state.
	Engine.max_fps = prior_max_fps
	var response: Array = replies[0]
	http.queue_free()
	var latency := (Time.get_ticks_msec() - started) / 1000.0
	if response[0] != HTTPRequest.RESULT_SUCCESS:
		return {"ok":false, "error":"timeout" if response[0] == HTTPRequest.RESULT_TIMEOUT else "transport_error", "latency":latency, "usage":{}}
	if response[1] < 200 or response[1] >= 300:
		return {"ok":false, "error":"http_%s" % response[1], "latency":latency, "usage":{}}
	var parsed: Variant = JSON.parse_string(response[3].get_string_from_utf8())
	return decode_envelope(parsed, latency)

static func decode_envelope(parsed: Variant, latency: float) -> Dictionary:
	var failure := {"ok":false, "error":"malformed_envelope", "latency":latency, "usage":{}}
	if not parsed is Dictionary or not parsed.get("choices") is Array or parsed.choices.is_empty() or not parsed.choices[0] is Dictionary:
		return failure
	var choice: Dictionary = parsed.choices[0]
	var usage: Dictionary = {}
	if parsed.get("usage") is Dictionary:
		for field in ["prompt_tokens", "completion_tokens"]:
			if parsed.usage.get(field) is float or parsed.usage.get(field) is int:
				if is_finite(float(parsed.usage[field])):
					usage[field] = clampi(int(parsed.usage[field]), 0, 1000000000)
	failure.usage = usage
	if not choice.get("message") is Dictionary:
		return failure
	var message: Dictionary = choice.message
	if message.get("refusal") != null and not str(message.refusal).is_empty():
		failure.error = "refusal"
		return failure
	if choice.get("finish_reason", "stop") not in ["stop", null]:
		failure.error = "incomplete_response"
		return failure
	if not message.get("content") is String or message.content.strip_edges().is_empty():
		failure.error = "empty_response"
		return failure
	# Deliberately ignore reasoning_content, reasoning, tool calls and all other
	# provider-specific fields. The caller validates content, never saves raw text.
	return {"ok":true, "content":message.content, "latency":latency, "usage":usage}
