extends "res://tests/LibraryRearRoadCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("rear-road-paving-priority-v74",Vector3(190,64,-344),Vector3(120,4,-378))
	var report:Dictionary={"captures":captures,"failures":failures,"scope":"visual only;collision unchanged;lotus walk terminates on rear sidewalk rather than carriageway"}
	FileAccess.open("res://tests/artifacts/rear_apron_visual_v74.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("REAR_APRON_VISUAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
