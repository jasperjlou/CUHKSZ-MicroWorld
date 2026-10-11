extends "res://tests/VisualCampusCapture.gd"
## Focused milestone for five bespoke buildings. One initial fixture, then continuous walking.

func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="landmark-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world)
	await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("zhang",Vector3(0,8,-389),Vector3(-65,11,-420))
	await capture("labs",Vector3(-92,5.3,-489),Vector3(-92,7,-550))
	await capture("lee",Vector3(-160,13,-496),Vector3(-120,11,-530))
	await capture("tu",Vector3(0,13,-502),Vector3(-64,14,-535))
	await capture("shaw-east",Vector3(0,18,-495),Vector3(80,18,-540))
	await capture("shaw-west",Vector3(99,15,-608),Vector3(145,23,-640))
	world.player.position=Vector3(0,2.54,-420);world.player.velocity=Vector3.ZERO
	world.player.set_physics_process(true);world.player.agent_controlled=true
	await frames(20)
	var route: Array=[
		[Vector3(-65,2.24,-420),"Zhang courtyard"],[Vector3(0,2.24,-420),"mall return"],
		[Vector3(0,2.24,-490),"labs approach"],[Vector3(-92,2.24,-490),"research passage entrance"],
		[Vector3(-92,2.24,-534),"research passage middle"],[Vector3(-92,2.24,-578),"research passage exit"],
		[Vector3(8,2.24,-584),"labs south return"],[Vector3(-25,2.24,-584),"Tu stair approach"],
		[Vector3(-25,2.24,-559.96),"Tu stair foot"],[Vector3(-41,6.965,-559.96),"Tu upper landing"],
		[Vector3(-25,2.24,-559.96),"Tu stair descent"],[Vector3(0,2.24,-560),"mall crossing"],
		[Vector3(35,2.24,-535),"Shaw East approach"],[Vector3(52,2.24,-535),"Shaw East entrance"],
		[Vector3(80,2.24,-540),"Shaw East courtyard"],[Vector3(87,2.24,-554.28),"Shaw East stair foot"],
		[Vector3(70,7.165,-554.28),"Shaw East upper landing"],[Vector3(87,2.24,-554.28),"Shaw East stair descent"],
		[Vector3(80,2.24,-540),"Shaw East court return"],[Vector3(52,2.24,-535),"Shaw East exit"],
		[Vector3(35,2.24,-600),"Shaw West south bypass"],[Vector3(110,2.24,-695),"Shaw West approach"],
		[Vector3(110,2.24,-640),"Shaw West front path"],[Vector3(121,2.24,-640),"Shaw West entrance"],
		[Vector3(145,2.24,-640),"Shaw West courtyard"]]
	for leg: Array in route:
		if not await walk(leg[0],leg[1]):break
		print("LANDMARK_ROUTE ",leg[1]," ",world.player.position)
	report_and_quit()

func report_and_quit() -> void:
	var report: Dictionary={"captures":captures,"failures":failures,"continuous_physical_legs":legs,"fixture_start":[0,2.54,-420],"no_teleport_during_route":true,"building_count":world.builder.buildings.size(),"route_count":world.data.routes.size(),"build_ms":world.built_ms,"true_north_calibrated":false}
	FileAccess.open("res://tests/artifacts/landmark_buildings_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LANDMARK_BUILDINGS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
