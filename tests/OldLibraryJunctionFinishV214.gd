extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	world.player.hide()
	await capture("old-library-junction-v214-final-overview",Vector3(-30,17,-662),Vector3(-12,2.6,-683))
	await capture("old-library-junction-v214-final-court",Vector3(-25,3.8,-676.4),Vector3(-53,3.1,-682))
	FileAccess.open("res://tests/artifacts/old_library_junction_finish_v214.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"captures":captures,"failures":failures,"fixtures":0,"scope":"non-collision paving/curb finish only; retained initial20walking legs"},"	"))
	print("OLD_LIBRARY_JUNCTION_V214 ",JSON.stringify({"legs":legs.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
