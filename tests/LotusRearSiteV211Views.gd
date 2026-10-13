extends "res://tests/LibraryLowerRearV150.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("pond-rear-v211-accepted-walk",Vector3(121,4,-361),Vector3(118,3,-340))
	await capture("pond-rear-v211-accepted-grade",Vector3(128,9,-355),Vector3(117,3,-332))
	await capture("pond-rear-v211-accepted-road",Vector3(133,8,-344),Vector3(116,3,-372))
	FileAccess.open("res://tests/artifacts/lotus_rear_site_v211_views.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"failures":failures,"scope":"retire overlapping obsolete lotus_east_bank visual,collision unchanged from finish"},"\t"))
	print("LOTUS_REAR_SITE_V211_VIEWS ",JSON.stringify({"failures":failures}));quit(0 if failures.is_empty() else 1)
