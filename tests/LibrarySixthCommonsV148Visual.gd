extends "res://tests/LibrarySixthCommonsV148.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-commons-v148-lounge-finish",p6(960,650,22.45),p6(1080,740,22.35))
	FileAccess.open("res://tests/artifacts/library_sixth_commons_v148_visual.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"scope":"Chair-only cloth grain;collision unchanged"},"\t"))
	quit(0 if failures.is_empty() else 1)
