extends "res://tests/ShawEastDetailCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("room",Vector3(63.5,4,-516),Vector3(66,4,-522))
	var report: Dictionary={"captures":captures,"failures":failures,"build_ms":world.built_ms,"scope":"Room furniture moved clear of structural columns; no collision change"}
	FileAccess.open("res://tests/artifacts/shaw_east_room_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_EAST_ROOM_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
