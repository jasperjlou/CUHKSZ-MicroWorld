extends "res://tests/LibraryUpperPlanV110.gd"
func plan_view(y:float,label:String)->void:
	world.overview.projection=Camera3D.PROJECTION_ORTHOGONAL;world.overview.size=91
	world.overview.global_position=wp(-2,y,2);world.overview.look_at(wp(-2,y-3,2),Vector3.RIGHT)
	await frames(12);await RenderingServer.frame_post_draw
	var file="courtyard-refined-"+label+".png";root.get_texture().get_image().save_png("res://tests/artifacts/"+file);captures.append(file)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await plan_view(16.3,"library-upper-v110-plan-final")
	await capture("library-upper-v110-atrium-final",pp(710,650,14.6),pp(510,745,13.7))
	await capture("library-upper-v110-reading-final",pp(450,396,14.5),pp(410,55,14.4))
	await plan_view(24.2,"library-upper-v110-sixth-plan-final")
	await capture("library-upper-v110-sixth-rooms-final",pp(1000,1080,22.5),pp(910,980,22.4))
	var report={"version":world.data.version,"captures":captures,"failures":failures,"scope":"Final4F/6Fplan,correctedracks/602-605,subduedcarpet;wholecampusstillactive"}
	FileAccess.open("res://tests/artifacts/library_upper_plan_v110_final_views.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_UPPER_FINAL_VIEWS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
