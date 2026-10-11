extends "res://tests/ZhangDatumV137.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true;building=world.builder.buildings.zhang_lingbin
	await capture("zhang-datum-v137-bridge",pos(-21.5,30,6.6),pos(-21.5,13,5.3))
	quit(0 if failures.is_empty() else 1)
