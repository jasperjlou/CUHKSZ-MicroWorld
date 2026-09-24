extends Node
signal event_emitted(record: Dictionary)
var sequence := 0

func reset() -> void:
	sequence = 0

func emit_event(event_type: String, actor: String = "player", data: Dictionary = {}) -> void:
	sequence += 1
	var seconds: float = GameState.get_value("current_game_time", GameState.START_TIME)
	event_emitted.emit({
		"sequence": sequence,
		"timestamp": snappedf(float(GameState.get_value("elapsed", 0.0)), 0.001),
		"game_time": GameState.format_time(seconds, true),
		"game_time_seconds": seconds,
		"actor": actor, "event": event_type, "data": data.duplicate(true)
	})
