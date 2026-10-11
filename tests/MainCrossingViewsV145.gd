extends "res://tests/ZhangDatumV137.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("main-crossing-v145-overview",Vector3(-39,24,-657),Vector3(-13,2.24,-683))
	await capture("main-crossing-v145-approach",Vector3(-9,4.1,-667),Vector3(-20.5,3,-678))
	await capture("main-crossing-v145-corner",Vector3(-20.5,4,-689),Vector3(-7.9,3,-694))
	FileAccess.open("res://tests/artifacts/main_crossing_v145_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"));quit()
