extends "res://tests/LibraryRearRoadCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("shaw-paver-avenue-v75",Vector3(42,4.1,-501),Vector3(43,5,-562))
	await capture("shaw-paver-side-branch-v75",Vector3(49,4.1,-499),Vector3(108,7,-499))
	await capture("shaw-student-garden-v75",Vector3(46,4.1,-494),Vector3(63,12,-405))
	await capture("shaw-paver-overview-v75",Vector3(8,62,-475),Vector3(88,7,-525))
	await fixture(site(30,-476)+Vector3.UP*.3,[
		[site(36,-487),"student garden paver transition"],[site(42,-499),"Shaw promenade junction"],
		[site(42,-533),"paver avenue along tree strip"],[site(42,-560),"main door apron"],
		[Vector3(49.1,2.24,-560),"existing main stair foot"],[Vector3(56,2.69,-560),"existing main entrance retained"],
		[site(42,-560),"main entrance return"],[site(42,-574),"pavers meet curved street walk"],
		[site(42,-499),"promenade back to side junction"],[site(70,-499),"side branch below end wing"],
		[site(94,-499),"grade transition foot"],[site(106,-499),"side branch fitted gentle rise"],
		[site(120,-499),"side branch reaches raised rear approach"],[site(122,-510),"branch joins rear road"],
		[site(120,-499),"raised junction reverse"],[site(106,-499),"side branch descent upper"],
		[site(94,-499),"side branch descent foot"],[site(70,-499),"side wing return"],
		[site(42,-499),"return to promenade"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"build_ms":world.built_ms,"scope":"paver approach,retained front stair,and new fitted side-to-rear-grade link;not actual road survey or complete building fidelity","no_teleport_within_fixture":true}
	FileAccess.open("res://tests/artifacts/shaw_promenade_v75.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_PROMENADE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
