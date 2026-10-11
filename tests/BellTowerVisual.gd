extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("bell-site-reviewed-v63",Vector3(1,45,-765),Vector3(35,32,-805))
	await capture("bell-apron-reviewed-v63",Vector3(35,10,-780),Vector3(35,5,-804))
	print("BELL_TOWER_VISUAL ",JSON.stringify({"captures":captures,"failures":failures}));quit(0 if failures.is_empty() else 1)
