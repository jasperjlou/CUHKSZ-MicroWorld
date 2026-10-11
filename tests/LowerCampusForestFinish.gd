extends "res://tests/LowerCampusIntegrationFinish.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("main-lawn",Vector3(-190,180,-12),Vector3(20,0,-275))
	await capture("lower-district",Vector3(-245,220,-490),Vector3(14,0,-780))
	var report: Dictionary={"captures":captures,"failures":failures,"render_samples":render_samples,"build_ms":world.built_ms,"scope":"Final forest palette and irregular edge only; four ground-level integration views and unchanged collision results reused"}
	FileAccess.open("res://tests/artifacts/lower_campus_forest_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LOWER_FOREST_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
