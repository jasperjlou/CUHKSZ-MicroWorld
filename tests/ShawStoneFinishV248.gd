extends "res://tests/LibraryLowerLevelCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(20)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("shaw-stone-v248-final-front",Vector3(69,4.1,-584),Vector3(70,3.25,-575.5))
	await capture("shaw-stone-v248-final-garden",Vector3(77,4.5,-579),Vector3(71,2.85,-575.6))
	FileAccess.open("res://tests/artifacts/shaw_stone_finish_v248.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"scope":"stone material only;6 legs and3rays retained from first run,not repeated"},"\t"))
	print("SHAW_STONE_FINISH_V248 ",JSON.stringify({"captures":captures,"failures":failures}));quit(0 if failures.is_empty() else 1)
