extends "res://tests/LibraryRearRoadCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("shaw-paver-avenue-final-v75",Vector3(42,4.1,-501),Vector3(43,5,-562))
	await capture("shaw-paver-side-final-v75",Vector3(49,4.1,-499),Vector3(108,7,-499))
	await capture("shaw-paver-overview-final-v75",Vector3(8,62,-475),Vector3(88,7,-525))
	var report:Dictionary={"captures":captures,"failures":failures,"scope":"visual finish only;paver cross-slope mesh,colour,straight lamps and planting;route colliders unchanged"}
	FileAccess.open("res://tests/artifacts/shaw_promenade_visual_v75.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_PROMENADE_VISUAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
