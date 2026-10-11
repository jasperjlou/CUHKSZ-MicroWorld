extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="shaw-west-detail-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("front",Vector3(102,17,-611),Vector3(145,24,-650))
	await capture("terraces",Vector3(109,22,-661),Vector3(132,23,-654))
	await capture("entry",Vector3(120,4.1,-651),Vector3(140,5,-637))
	await capture("court",Vector3(138,4,-640),Vector3(149,5,-625))
	await capture("public-room",Vector3(149,4,-623),Vector3(144,4,-613))
	await capture("podium",Vector3(145,8.9,-656),Vector3(139,8,-629))
	await fixture(Vector3(119,2.54,-640),[
		[Vector3(145,2.24,-640),"retained west courtyard entrance"],[Vector3(145,2.24,-617),"new shared room doorway"],
		[Vector3(140,2.24,-617),"shared room side aisle"],[Vector3(145,2.24,-617),"shared room return"],
		[Vector3(145,2.24,-640),"courtyard return"],[Vector3(127,2.24,-640),"outer stair approach"],
		[Vector3(123,2.24,-640),"outside front column line"],[Vector3(123,2.24,-629.5),"outer stair forecourt"],
		[Vector3(126,2.24,-629.5),"outer stair foot"],[Vector3(141.6,7.165,-629.5),"outer stair ascent"],
		[Vector3(145,7.165,-629.5),"podium rail opening"],[Vector3(145,7.165,-658),"open planted podium"],
		[Vector3(145,7.165,-629.5),"podium return"],[Vector3(141.6,7.165,-629.5),"stair landing return"],
		[Vector3(126,2.24,-629.5),"outer stair descent"],[Vector3(121,2.24,-640),"entrance path return"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"build_ms":world.built_ms,"no_teleport_within_each_fixture":true,"scope":"Shaw West revised public base, new room and exterior stair; upper residential terraces visually refined, no private room access implied"}
	FileAccess.open("res://tests/artifacts/shaw_west_detail_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_WEST_DETAIL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
