extends "res://tests/StudentThirdRoomsV220.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(18)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("student-ceiling-v222-room",third(750,660,10.5),third(470,530,13.2))
	await capture("student-ceiling-v222-entry",third(680,520,10.5),third(680,650,14.3))
	await capture("student-ceiling-v222-upper",third(480,630,14.1),third(650,580,15.45))
	await capture("student-ceiling-v222-soffit",third(450,585,10.5),third(460,650,11.6))
	FileAccess.open("res://tests/artifacts/student_hall_ceiling_v222.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"scope":"Photo-supported ceiling finish only; no structural collision edits; skylight unresolved"},"\t"))
	quit()
