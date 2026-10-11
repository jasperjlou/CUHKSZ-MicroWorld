extends "res://tests/LibraryLowerLevelCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-remote-stair-polished-v73",wp(-35.8,1.8,-8.3),wp(-38.7,3.0,-15.5))
	await capture("library-remote-toilets-polished-v73",wp(-30.5,1.8,-20),wp(-34,1.8,-21))
	await capture("library-remote-upper-polished-v73",wp(-30,18.6,-19.8),wp(-34,18.6,-19.8))
	FileAccess.open("res://tests/artifacts/library_remote_core_visual_v73.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"failures":failures,"scope":"visual only:retired decorative rail crossing shaft and toilet wall seam covers;collision routes unchanged"},"\t"))
	quit(0 if failures.is_empty() else 1)
