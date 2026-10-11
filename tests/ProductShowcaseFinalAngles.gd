extends "res://tests/ProductShowcaseViews.gd"
func _initialize() -> void:
	selected_ids=["gate","library-lower","zhang","research"]
	view_suffix="angles_final"
	run.call_deferred()
