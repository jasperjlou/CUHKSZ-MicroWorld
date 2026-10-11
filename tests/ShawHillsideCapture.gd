extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="shaw-hill-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("court",Vector3(139,4,-640),Vector3(174,5,-632))
	await capture("rear-walk",Vector3(170.5,4,-677),Vector3(172,4.5,-620))
	await capture("retaining",Vector3(168,5,-619),Vector3(184,6,-632))
	await capture("overall",Vector3(111,77,-583),Vector3(161,9,-639))
	await capture("district",Vector3(-245,220,-490),Vector3(14,0,-780))
	await capture("main-lawn",Vector3(-190,180,-12),Vector3(20,0,-275))
	await fixture(Vector3(145,2.54,-640),[
		[Vector3(160,2.24,-640),"rear wing ground arcade"],[Vector3(170.5,2.24,-640),"mountain-foot walk"],
		[Vector3(170.5,2.24,-601),"rear walk first return"],[Vector3(138,2.24,-601),"first corner to forecourt"],
		[Vector3(170.5,2.24,-601),"first corner return"],[Vector3(170.5,2.24,-679),"full rear walk"],
		[Vector3(138,2.24,-679),"opposite corner return"],[Vector3(121,2.24,-679),"front outside corner"],
		[Vector3(121,2.24,-640),"retained main entrance"],[Vector3(145,2.24,-640),"courtyard return"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"build_ms":world.built_ms,"no_teleport_within_each_fixture":true,"scope":"Fitted West rear terrain and outside walk; retained main entrance and courtyard return. Other district interiors unchanged."}
	FileAccess.open("res://tests/artifacts/shaw_hillside_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_HILLSIDE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
