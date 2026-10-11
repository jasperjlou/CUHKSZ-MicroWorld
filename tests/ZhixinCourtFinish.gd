extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("zhixin-court-v76",Vector3(1,4.3,-733),Vector3(-38,10,-733))
	await capture("zhixin-inner-wing-v76",Vector3(-22,4.3,-721),Vector3(-29,10,-751))
	await capture("main-square-pavers-v76",Vector3(-8.1,3.7,-700),Vector3(-8.1,2.35,-716))
	await capture("zhixin-street-overview-v76",Vector3(-7,48,-674),Vector3(-17,8,-733))
	# Continue only the failed column-alignment leg and remaining affected links.
	await fixture(Vector3(-33,2.54,-733),[
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
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"retained_initial_legs":7,"scope":"Correct column-side aisle and remaining V76 routes;material/mullion finish does not alter prior route collision"}
	FileAccess.open("res://tests/artifacts/zhixin_court_finish_v76.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ZHIXIN_COURT_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
