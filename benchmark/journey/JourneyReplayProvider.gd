extends "res://benchmark/providers/Provider.gd"
var actions: Array = []
var plan: Array = []
var cursor := 0

func complete(context: Dictionary) -> Dictionary:
	if context.payload.kind == "plan":
		return {"ok":true,"content":JSON.stringify({"plan":plan}),"usage":{},"latency":0.0}
	if cursor >= actions.size():
		return {"ok":false,"error":"replay_exhausted","usage":{},"latency":0.0}
	var action: Dictionary = actions[cursor]
	cursor += 1
	return {"ok":true,"content":JSON.stringify(action),"usage":{},"latency":0.0}
