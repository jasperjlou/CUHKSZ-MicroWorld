extends "res://tests/StudentThirdRoomsV220.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(18)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("student-hall-v221-door-faces",third(490,536,10.5),third(425,536,10.3))
	FileAccess.open("res://tests/artifacts/student_multi_hall_v221_door_visual.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"scope":"Final non-colliding door detail only; physical geometry unchanged"},"\t"))
	quit()
