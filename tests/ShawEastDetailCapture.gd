extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="shaw-east-detail-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("whole",Vector3(12,18,-495),Vector3(80,18,-540))
	await capture("louver",Vector3(41,16,-512),Vector3(60,20,-516))
	await capture("entry",Vector3(48,4.2,-541),Vector3(68,5,-548))
	await capture("court",Vector3(76,4.2,-548),Vector3(79,12,-538))
	await capture("room",Vector3(63.5,4,-516),Vector3(66,4,-522))
	await capture("roofwalk",Vector3(61,8.9,-540),Vector3(68,8,-556))
	await fixture(Vector3(48,2.54,-535),[
		[Vector3(56,2.24,-535),"east forecourt"],[Vector3(56,2.24,-518.24),"north room approach"],
		[Vector3(64,2.24,-518.24),"north room doorway"],[Vector3(56,2.24,-518.24),"north room exit"],
		[Vector3(56,2.24,-561.76),"south room approach"],[Vector3(64,2.24,-561.76),"south room doorway"],
		[Vector3(56,2.24,-561.76),"south room exit"],[Vector3(56,2.24,-540),"central opening"],
		[Vector3(80,2.24,-540),"retained east courtyard"],[Vector3(87,2.24,-554.28),"retained stair foot"],
		[Vector3(70,7.165,-554.28),"retained stair ascent"],[Vector3(62,7.165,-554.28),"aligned canopy roof"],
		[Vector3(62,7.165,-526.5),"public roof traverse before residential wing"],[Vector3(62,7.165,-554.28),"public roof return"],
		[Vector3(70,7.165,-554.28),"stair landing return"],[Vector3(87,2.24,-554.28),"stair descent"],
		[Vector3(80,2.24,-540),"court return"],[Vector3(48,2.24,-540),"main exit"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"build_ms":world.built_ms,"no_teleport_within_each_fixture":true,"scope":"East lower entrances, courtyard stair and aligned podium roof; private upper rooms not included"}
	FileAccess.open("res://tests/artifacts/shaw_east_detail_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_EAST_DETAIL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
