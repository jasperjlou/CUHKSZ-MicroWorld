extends "res://tests/LibrarySpacesCapture.gd"
## Last visual check only: student-centre ID correction changes decorative paving, not collision.
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("student-base",Vector3(48,4.5,-390),Vector3(71,5,-401))
	quit(0 if failures.is_empty() else 1)
