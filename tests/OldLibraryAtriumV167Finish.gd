extends "res://tests/OldLibraryAtriumV167.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("old-library-v167-curve-final",ap(16,2,1.85),ap(7,0,2.3))
	await capture("old-library-v167-floor",ap(13,3,1.85),ap(7,0,.45))
	FileAccess.open("res://tests/artifacts/old_library_atrium_v167_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"failures":failures,"scope":"Visual-only back-wall top closure and revised floor/shelf camera;107physical legs retained,collision unchanged."},"\t"))
	quit(0 if failures.is_empty() else 1)
