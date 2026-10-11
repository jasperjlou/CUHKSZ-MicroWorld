extends "res://tests/LibraryLowerLevelCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-layout-v102-110-front",wp(-3.8,1.8,-3.8),wp(-6.9,1.8,-.65))
	await capture("library-layout-v102-111-door",wp(-3.9,1.8,3.1),wp(-7,1.8,6))
	FileAccess.open("res://tests/artifacts/library_lower_layout_v102_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"physics":"Unchanged;use library_lower_layout_v102.json"},"\t"))
	quit(0 if failures.is_empty() else 1)
