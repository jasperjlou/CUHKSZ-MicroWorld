extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("admin-lookout-v40",Vector3(105,17,-176),Vector3(114,16,-165))
	await capture("admin-rear-step-v40",Vector3(101,16.4,-168),Vector3(114,15.5,-167))
	var report: Dictionary={"captures":captures,"failures":failures,"build_ms":world.built_ms,"scope":"Local-space slope handrail correction only; no collision or walkway changes after 18 passed legs"}
	FileAccess.open("res://tests/artifacts/admin_platforms_visual_v40.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ADMIN_PLATFORMS_VISUAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
