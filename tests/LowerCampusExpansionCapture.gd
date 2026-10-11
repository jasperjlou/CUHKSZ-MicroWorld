extends "res://tests/VisualCampusCapture.gd"
## One batch milestone: new exterior views, teaching stairs and the extended public route.

func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="lower-expansion-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world)
	await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("paving",Vector3(-4,3.8,-149),Vector3(-8,2.3,-165))
	await capture("teaching",Vector3(-5,7,-88),Vector3(-65,11,-115))
	await capture("teaching-court",Vector3(-57,5,-116),Vector3(-65,10,-135))
	await capture("corridor",Vector3(0,5,-398),Vector3(0,6,-456))
	await capture("shaw",Vector3(0,8,-503),Vector3(80,14,-540))
	await capture("main-square",Vector3(0,4.7,-709),Vector3(-20,7,-750))
	await capture("research",Vector3(25,9,-816),Vector3(91,20,-845))
	await capture("sports",Vector3(0,5,-825),Vector3(-10,10,-891))
	await capture("track",Vector3(-14,8,-1035),Vector3(-10,11,-890))
	world.player.set_physics_process(true);world.player.agent_controlled=true
	var route: Array=[
		[Vector3(0,0,0),"gate origin"],[Vector3(0,2.24,-82),"raised entry via stairs"],
		[Vector3(0,2.24,-115),"teaching approach"],[Vector3(-65,2.24,-115),"teaching courtyard"],
		[Vector3(-73,2.24,-131.28),"teaching stair foot"],[Vector3(-54.8,7.165,-131.28),"teaching first-floor landing"],
		[Vector3(-73,2.24,-131.28),"teaching stair descent"],[Vector3(-65,2.24,-115),"courtyard return"],
		[Vector3(0,2.24,-115),"mall return"],[Vector3(8,2.24,-275),"library-side promenade"],[Vector3(8,2.24,-385),"mall side promenade"],
		[Vector3(8,2.24,-426),"student corridor approach"],[Vector3(38,2.24,-426),"overhead link stair foot"],
		[Vector3(38,6.89,-444),"overhead link landing"],[Vector3(0,6.89,-444),"overhead link centre"],
		[Vector3(38,6.89,-444),"link return"],[Vector3(38,2.24,-426),"link stair descent"],
		[Vector3(8,2.24,-426),"public path return"],[Vector3(8,2.24,-584),"shaw promenade"],
		[Vector3(9,2.24,-735),"main-square sidewalk"],[Vector3(9,2.24,-805),"T-junction sidewalk"],
		[Vector3(0,2.24,-853),"sports hall portal"],[Vector3(0,2.24,-840),"sports approach return"],
		[Vector3(65,2.24,-840),"sports east bypass"],[Vector3(65,2.24,-929),"sports to field walkway"],
		[Vector3(-14,2.24,-940),"field forecourt"],[Vector3(-14,2.24,-964),"track entrance"]]
	for leg: Array in route:
		if not await walk(leg[0],leg[1]):break
		print("LOWER_ROUTE ",leg[1]," ",world.player.position)
	world.player.agent_controlled=false;world.overview.current=false;world.player.camera.current=true;world.ui.show();world.player.update_camera(1,true)
	await frames(12);await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/artifacts/lower-expansion-playable.png")
	report_and_quit()

func report_and_quit() -> void:
	var report: Dictionary={"captures":captures,"failures":failures,"continuous_physical_legs":legs,"no_teleport_during_route":true,"building_count":world.builder.buildings.size(),"route_count":world.data.routes.size(),"build_ms":world.built_ms,"draw_calls":RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),"manual_testing":false,"true_north_calibrated":false}
	FileAccess.open("res://tests/artifacts/lower_campus_expansion_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LOWER_CAMPUS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
