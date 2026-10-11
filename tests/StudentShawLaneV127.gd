extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	if DisplayServer.get_name()!="headless":
		await capture("student-shaw-v127-lower-out",Vector3(29,.05,-445),Vector3(29,.05,-478))
		await capture("student-shaw-v127-open-lane",Vector3(29,.08,-470),Vector3(31,2.2,-495))
		await capture("student-shaw-v127-return",Vector3(35,4.3,-498),Vector3(29,-.4,-450))
		await capture("student-shaw-v127-overview",Vector3(7,21,-493),Vector3(31,.8,-467))
		FileAccess.open("res://tests/artifacts/student_shaw_v127_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	await fixture(Vector3(18,2.54,-411),[
		[Vector3(18,-1.76,-431),"main stair down"],[Vector3(8,-1.76,-431),"lightwell side"],
		[Vector3(-12,-1.76,-431),"service gallery"],[Vector3(-12,-1.76,-443),"gift forecourt"],
		[Vector3(29,-1.76,-443),"cross hall to new lane"],[Vector3(29,-1.76,-457),"opened south wall"],
		[Vector3(29,-1.76,-466),"open stone lane"],[Vector3(29,.24,-480),"lane rising middle"],
		[Vector3(29,2.24,-494),"Shaw grade return"],[Vector3(42,2.24,-502),"Shaw paver junction"],
		[Vector3(42,2.24,-530),"Shaw east promenade"],[Vector3(42,2.24,-555),"Shaw entrance frontage"],
		[Vector3(42,2.24,-530),"promenade return"],[Vector3(42,2.24,-502),"paver junction return"],
		[Vector3(29,2.24,-494),"lane descending head"],[Vector3(29,.24,-480),"lane descending middle"],
		[Vector3(29,-1.76,-466),"lane lower level"],[Vector3(29,-1.76,-443),"covered hall return"],
		[Vector3(29,-1.76,-431),"lightwell east aisle"],[Vector3(18,-1.76,-431),"main stair foot"],
		[Vector3(18,2.24,-413),"main stair up"],[Vector3(30,2.24,-413),"upper student approach retained"],
		[Vector3(30,2.24,-400),"student side return"],[Vector3(0,2.24,-400),"central upper walkway"],
		[Vector3(0,2.24,-449),"upper mall to bridge"],[Vector3(0,2.24,-476),"upper mall continues separately"]])
	FileAccess.open("res://tests/artifacts/student_shaw_v127_physics.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"failures":failures,"fixtures":1,"scope":"D lower service to Shaw east promenade and return, including main stair and upper mall. Fitted grades, not full site verification."},"\t"))
	quit(0 if failures.is_empty() else 1)
