extends "res://tests/LibraryLowerLevelCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-registered-front-v45",wp(-8,35,70),wp(0,12,6))
	await capture("library-bent-front-v45",wp(-20,8,42),wp(-3,9,26))
	FileAccess.open("res://tests/artifacts/library_cores_visual_v45.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"build_ms":world.built_ms,"scope":"Final visible hard-paved forecourt only; no physical geometry changed after the 7-leg frontage pass."},"\t"))
	quit(0 if failures.is_empty() else 1)
