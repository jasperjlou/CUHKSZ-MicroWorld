extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="research-detail-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("passage",Vector3(-92,4.2,-494),Vector3(-92,8,-550))
	await capture("lee-entry",Vector3(-94,4,-521),Vector3(-104,4.2,-532))
	await capture("tu-ribbon",Vector3(-95,10,-520),Vector3(-85,12,-536))
	await capture("tu-road",Vector3(-3,14,-507),Vector3(-64,13,-535))
	await capture("tu-arcade",Vector3(-40.7,4.1,-508),Vector3(-41,4.3,-550))
	await capture("tu-terrace",Vector3(-32,9.8,-570),Vector3(-46,9,-558))
	await capture("hall",Vector3(-61,4,-535),Vector3(-82,4,-535))
	await fixture(Vector3(-92,2.54,-490),[
		[Vector3(-92,2.24,-530),"research passage to A entry"],[Vector3(-106,2.24,-530),"A glazed entry"],
		[Vector3(-143,2.24,-530),"A public hall through"],[Vector3(-106,2.24,-530),"A hall return"],
		[Vector3(-92,2.24,-530),"A passage exit"],[Vector3(-92,2.24,-535),"B entry approach"],
		[Vector3(-75,2.24,-535),"B passage-side doorway"],[Vector3(-35,2.24,-535),"B public hall to roadside"],
		[Vector3(-25,2.24,-535),"stair outside approach"],[Vector3(-25,2.24,-559.96),"Tu stair foot"],
		[Vector3(-40.5,6.965,-559.96),"Tu stair top"],[Vector3(-44.8,6.965,-559.96),"recessed terrace entry"],
		[Vector3(-44.8,6.965,-552.5),"terrace left end"],[Vector3(-44.8,6.965,-563.5),"terrace right end"],
		[Vector3(-44.8,6.965,-559.96),"terrace return"],[Vector3(-40.5,6.965,-559.96),"landing return"],
		[Vector3(-25,2.24,-559.96),"stair descent"],[Vector3(-25,2.24,-580),"outside south bypass"],
		[Vector3(-92,2.24,-580),"passage far end"],[Vector3(-92,2.24,-490),"full passage return"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"build_ms":world.built_ms,"no_teleport_within_each_fixture":true,"scope":"A/B public entrance halls, retained passage, Tu outer stair and newly recessed first terrace. Upper laboratory rooms are not reconstructed."}
	FileAccess.open("res://tests/artifacts/research_detail_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("RESEARCH_DETAIL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
