extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("sports-corner-v206-overall-final",Vector3(-166,12,-1132),Vector3(-119,0,-1091))
	await capture("sports-corner-v206-pedestrian-final",Vector3(-107,.05,-1131),Vector3(-119,-.1,-1090))
	await capture("sports-corner-v206-apron-final",Vector3(-131,.2,-1087),Vector3(-109,-.7,-1104))
	FileAccess.open("res://tests/artifacts/sports_corner_v206_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":0,"scope":"Corrected visual polygon winding only; terrain and solid planters unchanged. Reuse initial ten-leg traversal and three support checks."},"\t"))
	print("SPORTS_CORNER_V206_VIEWS ",failures);quit(0 if failures.is_empty() else 1)
