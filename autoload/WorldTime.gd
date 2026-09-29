extends Node
## Shared clock. GameState is its compatibility storage, not a second ticking clock.
signal advanced(previous: float, current: float)
var initial_time := 0.0
var time_scale := 1.0
var maximum_time := INF
var paused := false

var current_time: float:
	get: return float(GameState.get_value("current_game_time",initial_time))
var elapsed: float:
	get: return float(GameState.get_value("elapsed",0.0))

func configure(start: float, scale: float, maximum: float = INF) -> void:
	assert(is_finite(start) and is_finite(scale) and scale > 0 and maximum >= start)
	initial_time = start
	time_scale = scale
	maximum_time = maximum
	reset()

func reset() -> void:
	paused = false
	GameState.set_value("current_game_time",initial_time)
	GameState.set_value("elapsed",0.0)

func set_paused(value: bool) -> void:
	paused = value

func tick(delta: float) -> void:
	if paused or not is_finite(delta) or delta <= 0:
		return
	GameState.set_value("elapsed",elapsed+delta)
	advance(delta*time_scale)

func advance(game_seconds: float) -> void:
	if paused or not is_finite(game_seconds) or game_seconds < 0:
		return
	var previous := current_time
	GameState.set_value("current_game_time",minf(previous+game_seconds,maximum_time))
	advanced.emit(previous,current_time)

func snapshot() -> Dictionary:
	return {"current_time":current_time,"current_time_text":GameState.format_time(current_time,true),"elapsed_seconds":elapsed,"time_scale":time_scale,"paused":paused}
