extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("sports-crossing-v207-inside-finish",Vector3(-107,.04,-1105),Vector3(-106.5,-1.1,-1111))
	await capture("sports-crossing-v207-outside-finish",Vector3(-107,.05,-1131),Vector3(-106.5,-1.1,-1126))
	FileAccess.open("res://tests/artifacts/sports_crossing_v207_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":0,"scope":"Only gutter finish lifted3mm above coplanar asphalt; collision unchanged, retain final164profile samples."},"\t"))
	print("SPORTS_CROSSING_V207_VIEWS ",failures);quit(0 if failures.is_empty() else 1)
