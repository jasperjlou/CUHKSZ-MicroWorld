extends "res://tests/HallGlazedWingV178.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("hall-v178-final-exterior",hp178(48,6,33),hp178(32,4,15))
	await capture("hall-v178-final-waiting",hp178(25,2.6,8),hp178(43,3.4,20))
	await capture("hall-v178-final-window",hp178(40,2.6,17),hp178(45,4,12))
	FileAccess.open("res://tests/artifacts/hall_glazed_wing_visual_v178.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"scope":"Noncollision window head trim and removed redundant mullions; corrected exterior camera. Physical V178 fixture retained unchanged."},"\t"))
	print("HALL_WING_VISUAL_V178_DONE");quit()
