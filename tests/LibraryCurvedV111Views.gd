extends "res://tests/LibraryUpperPlanV110FinalViews.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-curved-v111-stair",pp(900,805,18.7),pp(705,750,18.2))
	await capture("library-curved-v111-atrium",pp(620,735,15.2),pp(716,775,20.7))
	await capture("library-curved-v111-books",pp(625,725,18.5),pp(556,813,18.7))
	await plan_view(24.2,"library-curved-v111-sixth")
	var report={"version":world.data.version,"captures":captures,"failures":failures}
	FileAccess.open("res://tests/artifacts/library_curved_v111_views.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	quit(0)
