extends "res://tests/LibraryLowerLevelCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-atrium-closed-lantern-v46",wp(9,10.6,10),wp(-12,16,1))
	FileAccess.open("res://tests/artifacts/library_atrium_visual_v46.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"build_ms":world.built_ms,"scope":"Visual-only lantern end sill closure; no collision changes after the 54+7 route checks."},"\t"))
	quit(0 if failures.is_empty() else 1)
