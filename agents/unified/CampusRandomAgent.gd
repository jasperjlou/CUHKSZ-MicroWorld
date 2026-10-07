extends RefCounted
var rng:=RandomNumberGenerator.new()
func reset_episode(seed_value: int=1) -> void:rng.seed=seed_value
func choose(_observation: Dictionary,available: Array) -> Dictionary:
	return available[rng.randi_range(0,available.size()-1)].duplicate() if not available.is_empty() else {}
