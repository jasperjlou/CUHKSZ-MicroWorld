extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-shore-final-v90",Vector3(13,4.05,-328),Vector3(23,3.8,-260))
	await capture("library-basin-final-v90",Vector3(6,15,-338),Vector3(36,2.6,-296))
	FileAccess.open("res://tests/artifacts/library_basin_visual_v90.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"failures":failures,"scope":"Remove unsourced bridge wayfinding board;10 unchanged physical legs and4 basin/bridge probes retained"},"\t"))
	quit(0 if failures.is_empty() else 1)
