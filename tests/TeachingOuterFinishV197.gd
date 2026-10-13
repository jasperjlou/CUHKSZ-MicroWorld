extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("teaching-outer-v197-finish-rise",Vector3(-148,-.62,-167),Vector3(-60,3,-167))
	await capture("teaching-outer-v197-finish-plan",Vector3(-183,44,-185),Vector3(-114,0,-136))
	FileAccess.open("res://tests/artifacts/teaching_outer_finish_v197.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"failures":failures,"scope":"Tree beds and benches moved from steep bank to walkway edge;central tested axis and road geometry unchanged"},"\t"))
	quit(0 if failures.is_empty() else 1)
