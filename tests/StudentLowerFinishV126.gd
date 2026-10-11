extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("student-lower-v126-final-stair",Vector3(18,5.4,-414),Vector3(16,-.8,-435))
	await capture("student-lower-v126-final-south",Vector3(-17,5,-470),Vector3(-17,-1,-450))
	await capture("student-lower-v126-final-card",Vector3(-14,.10,-438),Vector3(-19,.25,-422))
	FileAccess.open("res://tests/artifacts/student_lower_v126_finish_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"scope":"Visual-only finish: opening decals and stair stone; physical dimensions unchanged, obstructing props removed."},"\t"))
	quit(0 if failures.is_empty() else 1)
