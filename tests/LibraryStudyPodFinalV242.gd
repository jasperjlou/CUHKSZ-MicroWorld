extends "res://tests/LibraryGroundStairV103Capture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(30)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-pods-v242-final-doors",wp(-26.8,1.75,3.9),wp(-27.2,1.6,1.7))
	await capture("library-pods-v242-final-corner",wp(-33.5,1.8,3.8),wp(-30,2.15,.8))
	await capture("library-pods-v242-final-single",wp(-14.7,1.8,-6.8),wp(-14.7,1.7,-10.4))
	FileAccess.open("res://tests/artifacts/library_study_pod_final_v242.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"scope":"Single-sheet clear glass,unchanged equivalent box collision and corrected camera fixture;13initial door-volume results retained,no new walking results"},"\t"))
	print("LIBRARY_PODS_V242_FINAL failures=",failures);quit(0 if failures.is_empty() else 1)
