extends "res://tests/TeachingAArcadeV97Capture.gd"

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	if DisplayServer.get_name()!="headless":
		await capture("gate-lawn-v98-layout",Vector3(-4,40,-57),Vector3(0,2.3,-119))
		await capture("gate-lawn-v98-teaching",Vector3(2,4,-100),Vector3(-36,6,-109))
		await capture("gate-lawn-v98-avenue",Vector3(-20,4,-109),Vector3(-4,5,-173))
		await capture("gate-lawn-v98-gate",Vector3(0,4,-105),Vector3(-4,8,-28))
	else:
		await fixture(Vector3(-17.3,2.54,-56),[
			[Vector3(-25,2.24,-61),"side stair to lawn head"],
			[Vector3(-25,2.24,-114),"teaching side lawn walk"],
			[Vector3(-25,2.24,-132.75),"tree bed portal gap approach"],
			[Vector3(-35,2.24,-132.75),"TA entry approach"],
			[Vector3(-40,2.24,-132.75),"TA covered forecourt"],
			[Vector3(-45,2.24,-132.75),"TA portal"],
			[Vector3(-35,2.24,-132.75),"TA portal return"],
			[Vector3(-35,2.24,-150),"TA planting end"],
			[Vector3(-35,2.24,-160),"TA B transverse approach"],
			[Vector3(-35,2.24,-183),"flag platform teaching margin"],
			[Vector3(-38,2.24,-203),"teaching B threshold approach"],
			[Vector3(-38,2.24,-215),"teaching B forecourt"],
			[Vector3(-38,2.24,-203),"teaching B return"],
			[Vector3(-35,2.24,-183),"flag court return"],
			[Vector3(-35,2.24,-160),"A B junction return"],
			[Vector3(0,2.24,-160),"clear transverse mall"],
			[Vector3(0,2.24,-114),"uninterrupted inward avenue"],
			[Vector3(25,2.24,-114),"lawn inner end crossing"],
			[Vector3(25,2.24,-84),"ICC side lawn walk"],
			[Vector3(37,2.24,-84),"paired ICC tree islands gap"],
			[Vector3(37,2.24,-65),"ICC side return"],
			[Vector3(0,2.24,-65),"head path beyond ramp outlet"],
			[Vector3(-17.3,2.24,-56),"side stair rejoin"]])
	var report:Dictionary={"version":world.data.version,"physical_legs":legs,"captures":captures,"failures":failures,"fixtures":1,"no_teleport_within_fixture":true,"scope":"V98 lawn flanks and new tree beds, TA entry and B front connection; source metric registration remains fitted"}
	var suffix:="physics" if DisplayServer.get_name()=="headless" else "views"
	FileAccess.open("res://tests/artifacts/gate_lawn_v98_"+suffix+".json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	quit(0 if failures.is_empty() else 1)
