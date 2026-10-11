extends "res://tests/VisualCampusCapture.gd"
## Second completed batch: views and only the newly rebuilt public approaches.

func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="start-zone-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world)
	await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("cheng-dao",Vector3(9,9,-613),Vector3(-32,11,-646))
	await capture("le-tian",Vector3(8,7,-620),Vector3(46,9,-652))
	await capture("zhi-ren",Vector3(15,12,-759),Vector3(57,10,-734))
	await capture("zhi-xin",Vector3(-52,9,-694),Vector3(-115,9,-733))
	await capture("dao-yuan",Vector3(-5,7,-785),Vector3(-65,9,-805))
	await capture("research",Vector3(25,7,-810),Vector3(91,13,-845))
	world.player.position=Vector3(9,2.54,-615);world.player.velocity=Vector3.ZERO
	world.player.set_physics_process(true);world.player.agent_controlled=true
	await frames(20)
	var route: Array=[
		[Vector3(9,2.24,-646),"Cheng Dao approach"],[Vector3(-32,2.24,-646),"Cheng Dao open base"],
		[Vector3(9,2.24,-646),"Cheng Dao return"],[Vector3(9,2.24,-652),"Le Tian approach"],
		[Vector3(46,2.24,-652),"Le Tian glass entry"],[Vector3(9,2.24,-652),"Le Tian return"],
		[Vector3(9,2.24,-734),"Zhiren approach"],[Vector3(57,2.24,-734),"Zhiren garden court"],
		[Vector3(9,2.24,-734),"Zhiren return"],[Vector3(0,2.24,-703),"Zhi Xin north approach"],
		[Vector3(-45,2.24,-703),"Zhi Xin forecourt approach"],[Vector3(-45,2.24,-733),"Zhi Xin forecourt path"],
		[Vector3(-115,2.24,-733),"Zhi Xin ribbon court"],[Vector3(-45,2.24,-733),"Zhi Xin return"],
		[Vector3(-45,2.24,-777),"Dao Yuan north bypass"],[Vector3(-27,2.24,-777),"Dao Yuan forecourt approach"],
		[Vector3(-27,2.24,-805),"Dao Yuan entrance axis"],[Vector3(-65,2.24,-805),"Dao Yuan deep portal"],
		[Vector3(-27,2.24,-805),"Dao Yuan return"],[Vector3(9,2.24,-805),"public sidewalk return"],
		[Vector3(9,2.24,-845),"research approach"],[Vector3(9,2.24,-849),"research side approach"],
		[Vector3(91,2.24,-849),"research column bypass"],[Vector3(91,2.24,-845),"research sheltered base"]]
	for leg: Array in route:
		if not await walk(leg[0],leg[1]):break
		print("START_ZONE_ROUTE ",leg[1]," ",world.player.position)
	report_and_quit()

func report_and_quit() -> void:
	var report: Dictionary={"captures":captures,"failures":failures,"continuous_physical_legs":legs,"fixture_start":[9,2.54,-615],"no_teleport_during_route":true,"building_count":world.builder.buildings.size(),"route_count":world.data.routes.size(),"build_ms":world.built_ms,"true_north_calibrated":false}
	FileAccess.open("res://tests/artifacts/start_zone_buildings_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("START_ZONE_BUILDINGS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
