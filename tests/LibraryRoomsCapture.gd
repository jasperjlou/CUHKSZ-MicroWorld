extends "res://tests/LibraryLowerLevelCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-rooms-cluster",wp(-20,1.8,-9),wp(-30,1.8,-3))
	await capture("library-rooms-inner",wp(-13,1.8,-8),wp(-5,1.8,-13))
	await capture("library-rooms-diagonal",wp(13,1.8,-8),wp(7,1.8,-14))
	await capture("library-rooms-studios",wp(18,1.8,5),wp(21,1.8,-3))
	await capture("library-rooms-119",wp(33,1.8,-9),wp(27,1.8,-17))
	await capture("library-rooms-service",wp(-17,1.8,12),wp(-9,1.5,8))
	await fixture(wp(-18,.30,12),[
		[wp(-18,0,-8),"lower left entry"],[wp(-31,0,-8),"cluster back aisle"],
		[wp(-31,0,-4.5),"101 inward threshold"],[wp(-31,0,-8),"101 return"],
		[wp(-24,0,-8),"105 approach"],[wp(-24,0,-14.9),"105 entry"],
		[wp(-24,0,-8),"105 return"],[wp(-13,0,-8),"central cluster approach"],
		[wp(-10,0,-8),"108 approach"],[wp(-10,0,-10.1),"108 entry"],
		[wp(-10,0,-8),"108 return"],[wp(0,0,-8),"central aisle"],
		[wp(0,0,-13.1),"110 entry"],[wp(0,0,-8),"110 return"],
		[wp(0,0,-.7),"stair underside retained"],[wp(0,0,-8),"stair underside return"],
		[wp(18,0,-8),"cross aisle to right wing"],[wp(29,0,-8),"diagonal room approach"],
		[wp(32,0,-11.5),"119 door front"],[wp(29.7,0,-13.8),"119 inward threshold"],
		[wp(32,0,-11.5),"119 exit"],[wp(29,0,-8),"119 aisle return"],
		[wp(16.5,0,-8),"studio aisle approach"],[wp(16.5,0,8.5),"studio side aisle"],
		[wp(18,0,12),"right lower exit"],[wp(0,0,12),"main stair approach"],
		[wp(0,4.4,-4),"main stair ascent retained"]])
	var report:={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"Changed 1F room clusters and rotated right wing; sampled room entry and continuous shared route, not every door or whole-campus fidelity"}
	FileAccess.open("res://tests/artifacts/library_rooms_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_ROOMS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
