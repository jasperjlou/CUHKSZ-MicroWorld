extends "res://tests/VisualCampusCapture.gd"
## Complete batch only: exterior, occupied lower lobby, upper entry and nearby arcades.
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="library-spaces-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("pool-front",Vector3(8,10,-241),Vector3(78,12,-290))
	await capture("annex",Vector3(34,5,-242),Vector3(57,6,-262))
	await capture("ground-entry",Vector3(51,4,-272),Vector3(80,4,-272))
	await capture("lower-lobby",Vector3(87,4.2,-272),Vector3(89,4,-297))
	await capture("stairs",Vector3(61,4,-299),Vector3(78,7,-284))
	await capture("upper-lobby",Vector3(82,8.3,-289),Vector3(97,8,-290))
	await capture("teaching-base",Vector3(-49,4.5,-114),Vector3(-74,4,-118))
	await capture("student-base",Vector3(34,4.5,-390),Vector3(71,5,-401))
	world.player.position=Vector3(0,2.54,-275);world.player.velocity=Vector3.ZERO
	world.player.set_physics_process(true);world.player.agent_controlled=true;await frames(20)
	var route: Array=[
		[Vector3(38,2.24,-275),"pool bridge"],[Vector3(46,2.24,-272),"pool side paving"],
		[Vector3(65,2.24,-272),"G opening"],[Vector3(86,2.24,-272),"lower hall side aisle"],
		[Vector3(86,2.24,-290),"lower lobby cross aisle"],[Vector3(86,2.24,-299),"lower reading bay"],
		[Vector3(86,2.24,-272),"lower hall return"],[Vector3(65,2.24,-272),"G exit"],
		[Vector3(66,2.24,-290),"main stair foot"],[Vector3(80,6.64,-290),"main stair landing"],
		[Vector3(94,6.64,-290),"upper foyer"],[Vector3(80,6.64,-290),"upper return"],
		[Vector3(66,2.24,-290),"main stair descent"],[Vector3(66,2.24,-282),"wide stair foot"],
		[Vector3(80,6.64,-282),"wide stepped landing"],[Vector3(66,2.24,-282),"wide stair descent"],
		[Vector3(48,2.24,-282),"annex approach bypass"],[Vector3(48,2.24,-261.62),"annex front approach"],[Vector3(55,2.24,-261.62),"annex portico"],
		[Vector3(59,2.24,-261.62),"annex ground hall"],[Vector3(55,2.24,-261.62),"annex return"]]
	for leg: Array in route:
		if not await walk(leg[0],leg[1]):break
		print("LIBRARY_ROUTE ",leg[1]," ",world.player.position)
	report_and_quit()

func report_and_quit() -> void:
	var report: Dictionary={"captures":captures,"failures":failures,"continuous_physical_legs":legs,"fixture_start":[0,2.54,-275],"no_teleport_during_route":true,"build_ms":world.built_ms,"building_count":world.builder.buildings.size(),"route_count":world.data.routes.size(),"interior_plan":"inferred from named G/2F views, not surveyed","true_north_calibrated":false}
	FileAccess.open("res://tests/artifacts/library_spaces_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_SPACES ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
