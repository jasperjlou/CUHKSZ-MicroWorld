extends "res://tests/LibraryLowerLevelCapture.gd"
const Core := preload("res://world/visual_campus/LibraryServiceCores.gd")
func cp(index: int,x: float,y: float,z: float) -> Vector3:
	var p:=Core.local_point(index,Vector3(x,y,z));return wp(p.x,p.y,p.z)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-left-core-v45",wp(-18,1.8,9.4),wp(-28,1.8,9.4))
	await capture("library-core-lifts-v45",cp(0,3.6,1.8,-3.8),cp(0,-1,1.6,-5.2))
	await capture("library-core-stair-v45",cp(0,1.45,3.9,3.8),cp(0,-1.45,1.3,-1))
	await capture("library-diagonal-core-v45",wp(7,9,29),wp(-5,5,22))
	await capture("library-second-left-wing-v45",wp(-17,6.1,-5),wp(-28,6.1,8))
	for index in 2:
		var name: String="left" if index==0 else "diagonal"
		await fixture(cp(index,6,.3,-3.8),[
			[cp(index,0,0,-3.8),name+" ground core doorway"],
			[cp(index,-1.45,0,-3.0),name+" fire stair foot"],
			[cp(index,-1.45,2.2,3.8),name+" first half landing"],
			[cp(index,1.45,2.2,3.8),name+" half landing turn"],
			[cp(index,1.45,4.4,-3.8),name+" second floor arrival"],
			[cp(index,0,4.4,-3.8),name+" second floor lift lobby"],
			[cp(index,-1.45,4.4,-3),name+" second flight foot"],
			[cp(index,-1.45,6.6,3.8),name+" third floor half landing"],
			[cp(index,1.45,6.6,3.8),name+" upper half landing turn"],
			[cp(index,1.45,8.8,-3.8),name+" third floor arrival"],
			[cp(index,6,8.8,-3.8),name+" third floor side doorway"],
			[cp(index,1.45,8.8,-3.8),name+" third floor return"],
			[cp(index,1.45,6.6,3.8),name+" upper descending flight"],
			[cp(index,-1.45,6.6,3.8),name+" upper descending turn"],
			[cp(index,-1.45,4.4,-3.8),name+" down to second floor"],
			[cp(index,6,4.4,-3.8),name+" second floor side doorway"]])
	await fixture(wp(-18,4.7,9.4),[
		[wp(-19.9,4.4,0),"left second wing floor"],
		[wp(-25,4.4,-8),"left second reading wing"],
		[wp(-14,4.4,-8),"left wing to existing hall"],
		[wp(7,4.4,9),"hall to retained public stair approach"]])
	await fixture(wp(-18,.3,12),[
		[wp(-18,0,-8),"lower entry retained beside core"],
		[wp(-31,0,-8),"lower group rooms retained"],
		[wp(-31,0,-4.5),"101 doorway retained"],
		[wp(-31,0,-8),"101 return"],
		[wp(-18,0,-8),"lower room aisle return"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":4,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"Both service cores 1F-3F stairs and doors, left 2F floor connection, adjacent lower study aisle. Elevator operation and exact surveyed core placement not claimed."}
	FileAccess.open("res://tests/artifacts/library_cores_v45.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_CORES ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
