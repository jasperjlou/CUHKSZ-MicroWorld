extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("old-library-apron-v215-final-kerb",Vector3(-25,3.8,-676.4),Vector3(-53,3.1,-682))
	await capture("old-library-apron-v215-final-coach",Vector3(-95,5.3,-679.5),Vector3(-104,4.2,-673.9))
	FileAccess.open("res://tests/artifacts/old_library_apron_finish_v215.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"scope":"wire-shadow-only change plus noncollision wheels/lights; retain initial12legs; scene sun shadows enabled"},"	"))
	print("OLD_LIBRARY_APRON_FINISH_V215 ",JSON.stringify({"failures":failures}));quit(0 if failures.is_empty() else 1)
