extends "res://tests/LibraryLowerLevelCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(20)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("shaw-ground-v247-final-front",Vector3(38,4,-571),Vector3(45,3.1,-546))
	await capture("shaw-ground-v247-final-pavers",Vector3(42,4.1,-563),Vector3(42,2.4,-558))
	FileAccess.open("res://tests/artifacts/shaw_ground_finish_v247.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"scope":"paver tone and removal of procedural Shaw-entry sign only;no collision/route changes;prior16legs retained"},"\t"))
	print("SHAW_GROUND_FINISH_V247 ",JSON.stringify({"captures":captures,"failures":failures}));quit(0 if failures.is_empty() else 1)
