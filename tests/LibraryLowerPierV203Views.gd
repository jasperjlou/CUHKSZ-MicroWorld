extends "res://tests/LibraryGroundStairV103Capture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(40)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-lower-v203-seating-pier",gp(10.2,1.75,-5),gp(5,2.1,2.7))
	await capture("library-lower-v203-wood-stair",gp(-.2,1.8,-2.5),gp(0,3.3,7))
	await capture("library-lower-v203-opening-edge",gp(-3.4,6.2,9),gp(0,3.8,7))
	FileAccess.open("res://tests/artifacts/library_lower_pier_v203_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":0,"scope":"Correct perspective views; first V203 images retained as invalid orthographic captures, physical results unaffected."},"\t"))
	print("LIBRARY_LOWER_PIER_V203_VIEWS_DONE");quit(0 if failures.is_empty() else 1)
