extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(15);await RenderingServer.frame_post_draw
	var filename:="western-refined-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("sports-entrance",Vector3(-3,11,-829),Vector3(-1,10,-868))
	await capture("sports-field",Vector3(-12,11,-970),Vector3(-10,11,-914))
	await capture("reception",Vector3(-1,5,-873),Vector3(3,5,-883))
	await capture("old-gate",Vector3(-107,6,-837),Vector3(-132,8,-861))
	await capture("track",Vector3(92,66,-1100),Vector3(-10,4,-1018))
	await capture("district",Vector3(-184,85,-997),Vector3(-25,8,-907))
	await fixture(Vector3(0,2.54,-846),[
		[Vector3(0,2.24,-851),"sports front approach"],
		[Vector3(0,3.08,-859),"sports short entry stair"],
		[Vector3(0,3.08,-873),"sports open entrance"],
		[Vector3(0,3.08,-879),"sports reception passage"],
		[Vector3(0,3.08,-859),"sports reception return"],
		[Vector3(0,2.24,-851),"sports stair descent"]])
	await fixture(Vector3(-40,2.54,-932),[
		[Vector3(-40,7.04,-921),"sports rear gallery ascent"],
		[Vector3(20,7.04,-921),"sports elevated exterior gallery"],
		[Vector3(20,2.24,-932),"sports rear gallery descent"]])
	await fixture(Vector3(-120,2.54,-846),[
		[Vector3(-120,2.24,-877),"old gate pedestrian passage"],
		[Vector3(-120,2.24,-850),"old gate return"]])
	await fixture(Vector3(-14,2.54,-962),[
		[Vector3(-14,2.24,-1018),"track entry and pitch centre"],
		[Vector3(18,2.24,-1018),"football pitch"],
		[Vector3(-14,2.24,-962),"track exit"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":4,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"sports public entrance/reception/field gallery, old gate passage and track; source-based exteriors with explicitly estimated dimensions"}
	FileAccess.open("res://tests/artifacts/western_campus_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("WESTERN_CAMPUS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
