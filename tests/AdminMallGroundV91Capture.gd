extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("admin-inlay-v91",Vector3(6,4.05,-193),Vector3(59,7,-180))
	await capture("admin-flag-platform-v91",Vector3(6,4.0,-174),Vector3(-31,7,-180))
	await capture("admin-mall-arrangement-v91",Vector3(-52,47,-222),Vector3(13,3,-181))
	await capture("bc-transverse-stone-v91",Vector3(-41,4,-272.5),Vector3(-123,3.5,-272.5))
	await fixture(Vector3(-135,2.54,-272.5),[
		[Vector3(-37,2.24,-272.5),"BC rear to mall transverse"],
		[Vector3(-12,2.24,-272.5),"BC mall rejoin"],
		[Vector3(-12,2.24,-204),"teaching B side mall"],
		[Vector3(15,2.24,-204),"administration south court approach"],
		[Vector3(15,2.24,-180),"clear administrative axis"],
		[Vector3(58,2.24,-180),"administrative stair foot"],
		[Vector3(75,6.64,-180),"first administrative landing"],
		[Vector3(58,2.24,-180),"administrative stair descent"],
		[Vector3(-24,2.24,-180),"flag platform approach"],
		[Vector3(-29,2.66,-180),"three step flag platform"],
		[Vector3(-24,2.24,-180),"flag platform descent"],
		[Vector3(-12,2.24,-180),"clear mall axis return"],
		[Vector3(-12,2.24,-161),"east-gate direction departure"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"no_teleport_within_each_fixture":true,"scope":"V91 B/C transverse,clear administrative forecourt and source-visible flag platform;date/metric registration partial"}
	FileAccess.open("res://tests/artifacts/admin_mall_ground_v91.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ADMIN_MALL_V91 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
