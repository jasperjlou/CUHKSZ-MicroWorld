extends "res://tests/LibraryGroundStairV103Capture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(30)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-floor-v241-final-west",wp(-20.4,1.8,-7),wp(-32,.8,-9))
	await capture("library-floor-v241-final-pod",wp(-26.85,1.6,3.3),wp(-26.85,.2,.8))
	await capture("library-floor-v241-final-single",wp(-14.7,1.6,-7),wp(-14.7,.35,-10.4))
	FileAccess.open("res://tests/artifacts/library_lower_floor_v241_final.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"scope":"Material refinement only;V241 geometry and collision unchanged;initial874fragment overlap check retained"},"\t"))
	print("LIBRARY_FLOOR_V241_FINAL failures=",failures);quit(0 if failures.is_empty() else 1)
