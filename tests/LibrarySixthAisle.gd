extends "res://tests/LibraryLowerLevelCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await fixture(wp(26,21.1,-10),[[wp(13.5,20.8,-9),"room cluster return aligns before rear column"],[wp(14,20.8,13.2),"continuous side aisle passes both columns"],[wp(5,20.8,13.2),"room aisle reaches front core gallery"]])
	FileAccess.open("res://tests/artifacts/library_sixth_aisle_v47.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"failures":failures,"physical_legs":legs,"build_ms":world.built_ms,"scope":"Only the previously failed room-cluster-to-gallery transition; route aligns before the retained rear column rather than relying on endpoint tolerance."},"\t"))
	quit(0 if failures.is_empty() else 1)
