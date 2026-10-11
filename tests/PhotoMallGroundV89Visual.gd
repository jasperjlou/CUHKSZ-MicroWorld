extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("white-colonnade-final-v89",Vector3(35,4.05,-396.5),Vector3(-32,4.2,-396.5))
	await capture("zhang-lawn-drain-final-v89",Vector3(-7,4.1,-396.5),Vector3(-33,5,-424))
	await fixture(Vector3(2,2.54,-329),[
		[Vector3(12,2.24,-327.5),"courtyard pier outside approach"],
		[Vector3(16,2.24,-327.5),"courtyard pier bypass"],
		[Vector3(16,2.24,-331),"courtyard covered center"],
		[Vector3(2,2.24,-331),"courtyard center return"],
		[Vector3(2,2.24,-335),"main stone walk return"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"no_teleport_within_each_fixture":true,"scope":"White plaster finish and courtyard pier bypass;14 unaffected ground legs retained;initial straight route hit existing pier"}
	FileAccess.open("res://tests/artifacts/photo_mall_visual_v89.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("PHOTO_MALL_VISUAL_V89 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
