extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("old-library-window-bands-v88",Vector3(-45,13,-678),Vector3(-42,14,-691))
	await capture("old-library-grass-base-v88",Vector3(-20,3.95,-687.8),Vector3(-49,3.8,-690))
	await capture("old-library-road-elevation-v88",Vector3(-12,7,-665),Vector3(-36,10,-698))
	await capture("old-library-courtyard-retained-v88",Vector3(-5,5,-731),Vector3(-44,11,-726))
	await fixture(Vector3(-20.5,2.54,-688.1),[
		[Vector3(-61,2.24,-688.1),"narrow brick sidewalk beside planted verge"],
		[Vector3(-63.5,2.24,-690.8),"end of planted strip"],
		[Vector3(-50,2.24,-691.5),"glass setback drain approach"],
		[Vector3(-30,2.24,-691.5),"recessed facade apron"],
		[Vector3(-20.5,2.24,-688.1),"verge return to crossing"],
		[Vector3(-20.5,2.24,-676.4),"retained crossing and court-side pavement"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"Photo-based roadside wall/window/blinds,planted verge and setback drain;courtyard ribbons retained.Upper interiors and surveyed massing not verified."}
	FileAccess.open("res://tests/artifacts/old_library_facade_v88.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("OLD_LIBRARY_FACADE_V88 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
