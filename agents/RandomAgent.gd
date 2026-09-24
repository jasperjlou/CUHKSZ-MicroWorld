extends RefCounted
var rng := RandomNumberGenerator.new()
func reset_episode(seed_value: int) -> void:
	rng.seed = seed_value

func choose(_observation: Dictionary, actions: Array) -> Dictionary:
	return actions[rng.randi_range(0, actions.size() - 1)].duplicate(true) if not actions.is_empty() else {}
