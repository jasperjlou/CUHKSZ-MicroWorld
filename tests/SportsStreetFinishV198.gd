extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("sports-street-v198-final-corner",Vector3(-164,9,-1126),Vector3(-105,2,-1065))
	await capture("sports-street-v198-final-footway",Vector3(-130.9,.12,-1080),Vector3(-130.9,-.6,-1100))
	FileAccess.open("res://tests/artifacts/sports_street_finish_v198.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":0,"scope":"Final ochre tactile material and white twin-arm lamps; collision unchanged."},"\t"))
	print("SPORTS_STREET_V198_FINISH");quit(0 if failures.is_empty() else 1)
