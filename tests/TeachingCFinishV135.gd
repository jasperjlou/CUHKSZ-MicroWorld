extends "res://tests/TeachingCEntryV135.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	building=world.builder.buildings.teaching_c
	await capture("c-entry-v135-threshold",pos(18,40,2.1),pos(15,31,2))
	await capture("c-entry-v135-awning",pos(18,49,1.7),pos(18,46,3.7))
	quit(0 if failures.is_empty() else 1)
