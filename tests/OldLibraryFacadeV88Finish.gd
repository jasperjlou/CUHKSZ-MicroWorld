extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("old-library-window-final-v88",Vector3(-45,13,-678),Vector3(-42,14,-691))
	await capture("old-library-road-final-v88",Vector3(-12,7,-665),Vector3(-36,10,-698))
	await capture("old-library-court-final-v88",Vector3(-5,5,-731),Vector3(-44,11,-726))
	await fixture(Vector3(-50,2.54,-691.5),[
		[Vector3(-43,2.24,-691.5),"trimmed transverse glass corner"],
		[Vector3(-30,2.24,-691.5),"recessed apron continuation"],
		[Vector3(-20.5,2.24,-688.1),"planting strip end to crossing"],
		[Vector3(-20.5,2.24,-676.4),"retained court crossing"],
		[Vector3(-20.5,2.24,-688.1),"crossing return"],
		[Vector3(-30,2.24,-691.5),"return along recessed base"],
		[Vector3(-43,2.24,-691.5),"repaired corner return approach"],
		[Vector3(-50,2.24,-691.5),"trimmed glass corner return"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"Repair old cross-glazing beyond recessed outer line;8 affected forward/return legs.Three unaffected initial approach legs retained,failed initial fourth leg superseded."}
	FileAccess.open("res://tests/artifacts/old_library_facade_finish_v88.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("OLD_LIBRARY_FACADE_FINISH_V88 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
