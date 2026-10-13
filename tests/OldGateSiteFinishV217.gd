extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("old-gate-v217-final-entry",Vector3(-203,4.1,-790),Vector3(-156,8.4,-799))
	await capture("old-gate-v217-final-frontage",Vector3(-174,4.1,-752),Vector3(-156,5,-727))
	await capture("old-gate-v217-final-street",Vector3(-205,4.1,-772),Vector3(-199,3.6,-818))
	FileAccess.open("res://tests/artifacts/old_gate_site_v217_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"scope":"visual forecourt/gutter infill only; collision and28physical legs unchanged"},"\t"))
	print("OLD_GATE_SITE_V217_FINISH ",JSON.stringify({"captures":captures,"failures":failures}));quit(0 if failures.is_empty() else 1)
