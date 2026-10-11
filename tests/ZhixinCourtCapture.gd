extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("zhixin-court-v76",Vector3(1,4.3,-733),Vector3(-38,10,-733))
	await capture("zhixin-inner-wing-v76",Vector3(-22,4.3,-721),Vector3(-29,10,-751))
	await capture("main-square-pavers-v76",Vector3(-8.1,3.7,-700),Vector3(-8.1,2.35,-716))
	await capture("zhixin-street-overview-v76",Vector3(-7,48,-674),Vector3(-17,8,-733))
	# One continuous front walk from the Shaw bend, then courtyard/real door and back.
	await fixture(Vector3(-8.1,2.54,-636),[
		[Vector3(-8.1,2.24,-686),"Shaw bend to Zhixin frontage"],
		[Vector3(-8.1,2.24,-733),"narrow-brick library sidewalk"],
		[Vector3(-20,2.24,-733),"ochre apron to grey courtyard"],
		[Vector3(-44,2.24,-733),"courtyard between tree surrounds"],
		[Vector3(-51,2.24,-733),"old library real lobby door"],
		[Vector3(-44,2.24,-733),"lobby return"],
		[Vector3(-36.5,2.24,-733),"inner-wing approach"],
		[Vector3(-36.5,2.24,-700),"library wing public lower"],
		[Vector3(-36.5,2.24,-733),"library wing return"],
		[Vector3(-36.5,2.24,-765),"Zhixin teaching wing lower"],
		[Vector3(-36.5,2.24,-733),"teaching wing return"],
		[Vector3(-8.1,2.24,-733),"court exit to sidewalk"],
		[Vector3(-8.1,2.24,-758),"sidewalk past relocated flag plinth"],
		[Vector3(-8.1,2.24,-733),"return past flag plinth"],
		[Vector3(9,2.24,-734),"Main Square zebra crossing"],
		[Vector3(24,2.24,-734),"terrace stair approach"],
		[Vector3(43,4.64,-734),"terrace ascent"],
		[Vector3(24,2.24,-734),"terrace descent"],
		[Vector3(9,2.24,-734),"terrace return to brick walk"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"V76 F frontage,relocated flag/tree objects,inner ribbon facades and related courtyard/terrace access;full route registration and2026 renovated interior incomplete"}
	FileAccess.open("res://tests/artifacts/zhixin_court_v76.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ZHIXIN_COURT ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
