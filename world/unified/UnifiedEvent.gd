extends "res://world/campus_seamless/SeamlessEvent.gd"
func _process(delta: float) -> void:
	var clock_elapsed:=WorldTime.elapsed
	super._process(delta)
	elapsed=clock_elapsed;GameState.set_value("elapsed",clock_elapsed)
func advance(seconds: float) -> void:
	photo_time_cost+=seconds;WorldTime.advance(seconds)
