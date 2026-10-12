extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("ground-final-v183-tower-junction",Vector3(-12,12,-772),Vector3(112,9,-916))
	await capture("ground-final-v183-junction-near",Vector3(4.0,4.0,-807),Vector3(-4,2.4,-794))
	FileAccess.open("res://tests/artifacts/ground_junction_v183.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"failures":failures,"scope":"Trim visual-only old cross-street footway at main-road edge;collision unchanged"},"\t"))
	print("GROUND_JUNCTION_V183_DONE");quit()
