extends "res://tests/CourtyardRefinementCapture.gd"

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("white-colonnade-v89",Vector3(35,4.05,-396.5),Vector3(-32,4.2,-396.5))
	await capture("mall-lawns-v89",Vector3(-20,4.1,-392),Vector3(-14,4,-346))
	await capture("mall-arrangement-v89",Vector3(-62,61,-460),Vector3(10,2.8,-372))
	await capture("library-stone-approach-v89",Vector3(1,4.1,-348),Vector3(18,3,-327))
	await fixture(Vector3(2,2.54,-430),[
		[Vector3(2,2.24,-396.5),"main walk to white colonnade"],
		[Vector3(-35,2.24,-396.5),"white colonnade west opening"],
		[Vector3(-32,2.24,-396.5),"west stone walk turn"],
		[Vector3(-32,2.24,-435),"west walk toward Zhang"],
		[Vector3(2,2.24,-437),"south lawn edge crossing"],
		[Vector3(2,2.24,-396.5),"colonnade return"],
		[Vector3(35,2.24,-396.5),"white colonnade east opening"],
		[Vector3(35,2.24,-392),"student portal approach"],
		[Vector3(60,2.24,-392),"student ground portal"],
		[Vector3(35,2.24,-392),"student portal return"],
		[Vector3(35,2.24,-396.5),"white colonnade rejoin"],
		[Vector3(2,2.24,-396.5),"main walk rejoin"],
		[Vector3(2,2.24,-335),"east-gate direction stone walk"],
		[Vector3(2,2.24,-329),"library approach apron"],
		[Vector3(16,2.24,-329),"library courtyard interface"],
		[Vector3(2,2.24,-329),"library apron return"]])
	var report:Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"no_teleport_within_each_fixture":true,"scope":"V89 photo mall ground/white colonnade;metric registration and full campus fidelity unresolved"}
	FileAccess.open("res://tests/artifacts/photo_mall_ground_v89.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("PHOTO_MALL_V89 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
