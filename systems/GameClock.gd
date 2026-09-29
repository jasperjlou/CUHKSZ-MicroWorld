extends Node
signal time_expired
const RATE := 1.5
var deadline_emitted := false

func _ready() -> void:
	WorldTime.configure(GameState.START_TIME,RATE,GameState.END_TIME)

func _process(delta: float) -> void:
	WorldTime.set_paused(not GameState.get_flag("started") or GameState.get_flag("game_finished") or GameState.get_flag("paused") or GameState.get_flag("modal_open"))
	if WorldTime.paused:
		return
	WorldTime.tick(delta)
	_check_time(WorldTime.current_time)

func advance(seconds: float) -> void:
	WorldTime.advance(seconds)
	EventBus.emit_event("TIME_COST", "world", {"seconds": seconds, "reason": "photo"})
	_check_time(WorldTime.current_time)

func _check_time(seconds: float) -> void:
	if seconds >= GameState.DEADLINE and not deadline_emitted:
		deadline_emitted = true
		EventBus.emit_event("DEADLINE_PASSED", "world")
	if seconds >= GameState.END_TIME:
		time_expired.emit()
