extends "res://tests/LibraryLowerRearV150.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("colonnade-v213-final-walk",Vector3(-24,4,-396.4),Vector3(25,3.8,-396.4))
	await capture("colonnade-v213-final-stone",Vector3(-20,3.2,-397.6),Vector3(-15,2.4,-396.4))
	FileAccess.open("res://tests/artifacts/colonnade_rain_stone_finish_v213.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"scope":"existing PhotoMallGround pipes/drains/material visual refinement;collision unchanged,no route replay"},"\t"))
	print("COLONNADE_RAIN_STONE_V213 ",JSON.stringify({"failures":failures}));quit(0 if failures.is_empty() else 1)
