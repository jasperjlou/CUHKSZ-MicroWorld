extends "res://tests/StudentCourtFlightsV157.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("student-v157-first-panels",pp(185,506,1.8),pp(315,506,4.8))
	await capture("student-v157-middle-panels",pp(360,426,6.2),pp(555,426,8.0))
	await capture("student-v157-upper-panels",pp(530,355,11),pp(665,270,11))
	await capture("student-v157-courts-panels",pp(340,365,14),pp(730,300,12))
	FileAccess.open("res://tests/artifacts/student_court_flights_v157_panels.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"physical_legs":0,"scope":"Only visual panel face winding corrected; collisions unchanged,scoped accepted walks reused."},"\t"))
	print("STUDENT_COURT_FLIGHTS_V157_PANELS ",captures.size());quit()
