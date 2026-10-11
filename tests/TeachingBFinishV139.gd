extends "res://tests/ZhangDatumV137.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true;building=world.builder.buildings.teaching_b
	await capture("teaching-b-v139-lobby",pos(-13,42,2.0),pos(-10,31,2.0))
	FileAccess.open("res://tests/artifacts/teaching_b_v139_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
