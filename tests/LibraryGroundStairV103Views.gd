extends "res://tests/LibraryGroundStairV103Capture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-ground-v103-finish-tiers",gp(4,1.8,-3.5),gp(4,1.5,3))
	await capture("library-ground-v103-finish-rooms",wp(28.9,1.8,-6.1),wp(23.8,1.7,-3.2))
	await capture("library-ground-v103-finish-stacks",wp(10,1.8,3),wp(17,1.8,10))
	FileAccess.open("res://tests/artifacts/library_ground_stair_v103_views.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"failures":failures,"scope":"Material and right wing views only;no repeated physics"},"\t"))
	quit(0 if failures.is_empty() else 1)
