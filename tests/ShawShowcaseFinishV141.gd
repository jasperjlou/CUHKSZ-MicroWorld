extends "res://tests/RearShawShowcaseV141.gd"
func _initialize()->void:
	selected=["shaw-podium"]
	report_id="shaw_showcase_finish_v141"
	capture_suffix="v141-final"
	run.call_deferred()
