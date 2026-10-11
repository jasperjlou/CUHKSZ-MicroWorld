extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("daoyuan-front-finish-v55",Vector3(-3,7,-797),Vector3(-56,14,-805))
	await capture("daoyuan-portal-finish-v55",Vector3(-37,7,-807),Vector3(-57,9,-805))
	print("DAOYUAN_VISUAL_FINISH ",JSON.stringify({"captures":captures,"scope":"Final ground glazing and window band visual only;retain20 physical legs from V55."}));quit()
