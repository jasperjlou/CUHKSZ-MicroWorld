extends "res://tests/LibraryUpperPlanV110FinalViews.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-curved-v111-bridge",pp(880,775,23.1),pp(690,690,21.0))
	await capture("library-curved-v111-skylight",pp(715,780,24.0),pp(700,780,27.3))
	FileAccess.open("res://tests/artifacts/library_curved_v111_detail_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures},"\t"))
	quit(0)
