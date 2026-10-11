extends "res://tests/LibraryUpperPlanV110.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	world.overview.projection=Camera3D.PROJECTION_ORTHOGONAL;world.overview.size=91
	world.overview.global_position=wp(-2,16.3,2);world.overview.look_at(wp(-2,12.8,2),Vector3.RIGHT)
	await frames(12);await RenderingServer.frame_post_draw
	var file="courtyard-refined-library-upper-v110-plan.png";root.get_texture().get_image().save_png("res://tests/artifacts/"+file);captures.append(file)
	await capture("library-upper-v110-atrium",pp(635,625,14.6),pp(480,746,13.5))
	await capture("library-upper-v110-rear",pp(450,396,14.5),pp(410,55,14.4))
	await capture("library-upper-v110-fablab",pp(1010,500,14.5),pp(930,402,14.5))
	await capture("library-upper-v110-shell",wp(66,49,86),wp(-1,14,3))
	var report={"version":world.data.version,"captures":captures,"failures":failures,"scope":"Current4F orthographic cutaway,circulation and upper exterior;5/6F full visual audit remains open"}
	FileAccess.open("res://tests/artifacts/library_upper_plan_v110_views.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_UPPER_VIEWS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
