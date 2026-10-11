extends "res://tests/LibraryPlanCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("study",Vector3(77,12.7,-293),Vector3(85,12.1,-318))
	await capture("stair",Vector3(96,8.3,-282),Vector3(81,11.6,-282))
	await capture("terrace",Vector3(106,13,-306),Vector3(88,14,-292))
	var report: Dictionary={"captures":captures,"failures":failures,"build_ms":world.built_ms,"scope":"3F full ceiling underside and chair legs, visual-only final correction; unchanged collisions retain prior physical validation"}
	FileAccess.open("res://tests/artifacts/library_plan_visual_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_PLAN_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
