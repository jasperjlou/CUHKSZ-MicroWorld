extends Node
signal time_expired
const RATE := 1.5
var deadline_emitted := false

func _process(delta: float) -> void:
	if not GameState.get_flag("started") or GameState.get_flag("game_finished") or GameState.get_flag("paused") or GameState.get_flag("modal_open"):
		return
	GameState.set_value("elapsed", float(GameState.get_value("elapsed")) + delta)
	var seconds := minf(float(GameState.get_value("current_game_time")) + delta * RATE, GameState.END_TIME)
	GameState.set_value("current_game_time", seconds)
	_check_time(seconds)

func advance(seconds: float) -> void:
	var next := minf(float(GameState.get_value("current_game_time")) + seconds, GameState.END_TIME)
	GameState.set_value("current_game_time", next)
	EventBus.emit_event("TIME_COST", "world", {"seconds": seconds, "reason": "photo"})
	_check_time(next)

func _check_time(seconds: float) -> void:
	if seconds >= GameState.DEADLINE and not deadline_emitted:
		deadline_emitted = true
		EventBus.emit_event("DEADLINE_PASSED", "world")
	if seconds >= GameState.END_TIME:
		time_expired.emit()
