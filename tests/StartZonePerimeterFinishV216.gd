extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("start-perimeter-v216-final-walk",Vector3(-180.6,4.0,-670),Vector3(-181,3.7,-715))
	await capture("start-perimeter-v216-final-branch",Vector3(-154,4.4,-676.4),Vector3(-180,3.8,-680))
	FileAccess.open("res://tests/artifacts/start_zone_perimeter_v216_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"scope":"visual gutter ownership finish; no collision changes"},"\t"))
	print("START_PERIMETER_V216_FINISH ",JSON.stringify({"captures":captures,"failures":failures}));quit(0 if failures.is_empty() else 1)
