extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("student-lower-v126-final-south",Vector3(-17,5,-470),Vector3(-17,-1,-450))
	FileAccess.open("res://tests/artifacts/student_lower_v126_south_view.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"scope":"Only southern stair aperture after removing overlapping old woodland planting."},"\t"))
	quit(0 if failures.is_empty() else 1)
