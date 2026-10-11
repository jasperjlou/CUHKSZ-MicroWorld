extends "res://tests/CourtyardEnclosureCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("seating",Vector3(32,.2,-360),Vector3(35,3,-339))
	await capture("whole",Vector3(-15,38,-360),Vector3(49,4,-360))
	var report: Dictionary={"captures":captures,"failures":failures,"build_ms":world.built_ms,"scope":"Non-colliding continuous stair handrails only; all 20 physical legs reused from milestone"}
	FileAccess.open("res://tests/artifacts/courtyard_enclosure_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("COURTYARD_ENCLOSURE_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
