extends "res://tests/LibraryUpperPlanV110FinalViews.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-rare-v113-door",pp(584,775,18.5),pp(540,828,18.2))
	await capture("library-rare-v113-room",pp(540,850,18.5),pp(350,900,18.2))
	await capture("library-rare-v113-stair",pp(510,794,18.5),pp(470,727,19.3))
	await plan_view(20.0,"library-rare-v113-fifth")
	await plan_view(24.2,"library-rare-v113-sixth")
	FileAccess.open("res://tests/artifacts/library_rare_v113_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures},"\t"))
	quit(0)
