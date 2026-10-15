extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("old-library-planting-v253-street",Vector3(-25,3.8,-676.4),Vector3(-50,3.0,-689))
	await capture("old-library-planting-v253-front",Vector3(-31,3.9,-684.4),Vector3(-44,3,-689.4))
	await capture("old-library-planting-v253-crossing",Vector3(-17,7,-683),Vector3(-28,2.5,-689))
	await capture("old-library-planting-v253-end",Vector3(-69,5,-681),Vector3(-57,2.5,-690))
	FileAccess.open("res://tests/artifacts/old_library_planting_v253.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"collision_changed":false,"new_physical_legs":0,"scope":"photo-led planting/pavement interface;unchanged ground and collision;not full site registration"},"\t"))
	print("OLD_LIBRARY_PLANTING_V253 ",captures.size()," failures=",failures);quit(0 if failures.is_empty() else 1)
