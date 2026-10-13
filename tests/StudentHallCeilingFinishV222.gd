extends "res://tests/StudentThirdRoomsV220.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(18)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("student-ceiling-v222-final-room",third(750,660,10.5),third(470,530,13.2))
	await capture("student-ceiling-v222-final-upper",third(480,630,14.1),third(650,580,15.45))
	FileAccess.open("res://tests/artifacts/student_hall_ceiling_v222_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"scope":"Final aligned rib phase only; no physical changes"},"\t"))
	quit()
