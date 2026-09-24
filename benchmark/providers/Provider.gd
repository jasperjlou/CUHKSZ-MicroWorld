extends Node
# No environment or privileged state is part of the provider contract.
func begin_episode(_task_id: String, _seed_value: int) -> void:
	pass

func generate_action(context: Dictionary) -> Dictionary:
	return await complete(context)

func generate_plan(context: Dictionary) -> Dictionary:
	return await complete(context)

func complete(_context: Dictionary) -> Dictionary:
	return {"ok":false, "error":"not_implemented", "latency":0.0, "usage":{}}
