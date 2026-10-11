extends "res://tests/LibraryLowerLevelCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-pool-anniversary-v48",Vector3(-8,19,-214),Vector3(62,13,-294))
	await capture("library-pavilion-end-v48",wp(60,5,36),wp(34,4,16))
	await capture("library-water-fins-v48",wp(-29,2,52),wp(-28,5,28))
	await capture("library-pavilion-connection-v48",wp(40,21,43),wp(30,3,12))
	await fixture(Vector3(13,2.54,-275),[
		[Vector3(27,2.47,-275),"main pool crossing"],[Vector3(40,2.24,-275),"pool crossing to forecourt"],
		[wp(19,0,31),"pavilion walk approach"],[wp(21,0,24),"pavilion near corner"],
		[wp(45.5,0,24),"brick broadside walkway"],[wp(46,0,12),"glazed end walkway"],
		[wp(46,0,1),"pavilion far side connection"],[wp(46,0,12),"end walkway return"],
		[wp(45.5,0,24),"pavilion corner return"],[wp(21,0,24),"broadside return"],
		[wp(19,0,31),"forecourt return"],[Vector3(40,2.24,-275),"forecourt to pool bridge"],
		[Vector3(13,2.24,-275),"main pool crossing reverse"]])
	await fixture(wp(-18,.3,39),[
		[wp(-18,0,20),"dry lower doorway beside water"],[wp(-18,0,-8),"lower wing public aisle"],
		[wp(-18,0,39),"lower door return"],[Vector3(40,2.24,-308),"pool corner dry approach"],
		[Vector3(15,2.24,-308),"cross approach before enlarged water"],
		[Vector3(15,2.24,-329),"mall side of pool"],[Vector3(43,2.24,-329),"pool end to courtyard link"],
		[Vector3(15,2.24,-329),"pool end reverse"],[Vector3(15,2.24,-308),"mall return"]])
	await fixture(wp(5,.3,31),[[wp(17,4.4,18),"main entry stair retained beside pavilion"],[wp(18,4.4,10),"2F portal retained"],[wp(17,4.4,18),"2F exit"],[wp(5,0,30),"main stair descent"]])
	var surfaces: Array=[]
	for pair: Array in [[wp(33,1.5,25),wp(33,1.5,18)],[wp(47,2,13),wp(40,2,13)]]:
		var hit:=not world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(pair[0],pair[1])).is_empty();surfaces.append(hit)
		if not hit:failures.append("pavilion exterior collision")
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"pavilion_collision":surfaces,"build_ms":world.built_ms,"scope":"Pool-facing brick wall, perpendicular glazed pavilion end, adjoining ground paths, dry G doorway and main 2F stair. Not proof of exact dimensions, all pool outline or unseen pavilion interior."}
	FileAccess.open("res://tests/artifacts/library_pool_frontage_v48.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_POOL_FRONTAGE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
