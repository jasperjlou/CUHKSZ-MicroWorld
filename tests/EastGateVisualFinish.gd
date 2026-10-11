extends "res://tests/LowerCampusScopeReview.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("east-gate",Vector3(0,13,72),Vector3(0,12,-16))
	await capture("east-gate-entry",Vector3(-5,2.2,21),Vector3(8,10,-19))
	await capture("east-gate-inside",Vector3(0,13,-70),Vector3(0,12,-16))
	var report: Dictionary={"captures":captures,"failures":failures,"build_ms":world.built_ms,"version":world.data.version,"scope":"Final non-colliding entrance paving and vegetation; four origin-passage legs reused."}
	FileAccess.open("res://tests/artifacts/east_gate_visual_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("EAST_GATE_VISUAL_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
