extends "res://tests/LibraryRearRoadCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-asphalt-apron-final-v74",Vector3(131,5,-327),Vector3(99,10,-311))
	await capture("student-rear-connection-final-v74",Vector3(152,5,-409),Vector3(137,5,-397))
	await capture("library-student-rear-overview-final-v74",Vector3(190,64,-344),Vector3(120,4,-378))
	await fixture(site(127,-350)+Vector3.UP*.3,[
		[site(138,-350),"turn before building corner"],[site(146,-353),"beveled road bend"],
		[site(151,-360),"road outside rear wall"],[site(151,-373),"rear avenue joins straight"],
		[site(146,-373),"road to pedestrian strip"],[site(146,-358),"walk clears building corner"],
		[site(142,-349),"walk turns clear of building"],[site(137,-345),"walk bevel return"],
		[site(122,-345),"walk rejoins library side"]])
	var report:Dictionary={"captures":captures,"physical_legs":legs,"failures":failures,"build_ms":world.built_ms,"scope":"changed corner route only;apron tessellation and duplicate-render removal have no collision changes;19 prior physical records retained except old diagonal corner","no_teleport_within_fixture":true}
	FileAccess.open("res://tests/artifacts/rear_apron_finish_v74.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("REAR_APRON_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
