extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("old-library-court-v254-front",Vector3(-6,4.0,-728),Vector3(-37,5,-733))
	await capture("old-library-court-v254-floor",Vector3(-25,4,-735),Vector3(-36,2.4,-738))
	await capture("old-library-court-v254-entry",Vector3(-39,4,-733),Vector3(-49,3,-733))
	await capture("old-library-court-v254-side",Vector3(-19,4,-716),Vector3(-41,3,-712))
	FileAccess.open("res://tests/artifacts/old_library_court_v254.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"collision_changed":false,"new_physical_legs":0,"scope":"grey court material and flush perimeter; existing grades retained; not current-year or metric registration"},"\t"))
	print("OLD_LIBRARY_COURT_V254 ",captures.size()," failures=",failures);quit(0 if failures.is_empty() else 1)
