extends "res://tests/CourtyardRefinementCapture.gd"

func site(x: float,z: float) -> Vector3:
	return Vector3(x,world.builder.height(x,z),z)

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("rear-road-descent",Vector3(132,15,-228),Vector3(138,6,-323))
	await capture("rear-road-library",Vector3(147,13,-311),Vector3(82,12,-289))
	await capture("rear-road-student",Vector3(145,5,-373),Vector3(137,5,-448))
	await capture("rear-road-shaw",Vector3(140,6,-514),Vector3(92,14,-558))
	await capture("rear-road-overall",Vector3(232,108,-260),Vector3(116,6,-410))
	await fixture(site(132,-202)+Vector3.UP*.3,[
		[site(132,-250),"admin rear gentle descent"],[site(132,-290),"library rear road slope"],
		[site(132,-330),"library road foot"],[site(139,-410),"student back lane"],
		[site(147,-490),"Shaw rear approach"],[site(131,-536),"Shaw east back side"],
		[site(108,-575),"Shaw rear corner"],[site(108,-589),"Shaw south connector"],
		[site(87,-599),"Shaw cross road"],[site(61,-597),"Shaw frontage return"],
		[site(42,-575),"Shaw front pavement"]])
	await fixture(site(132,-330)+Vector3.UP*.3,[
		[site(132,-322),"library rear spur"],[site(121,-322),"library side paving"],
		[site(110,-326),"library rear-side corner"],[site(121,-322),"library spur return"],
		[site(132,-322),"back to avenue"],[site(132,-280),"reverse slope lower"],
		[site(132,-240),"reverse slope middle"],[site(132,-202),"reverse slope upper"]])
	var report:={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"build_ms":world.built_ms,"scope":"rear avenue graded route, back-to-front Shaw connection and library side spur; B1 remains separately unverified"}
	FileAccess.open("res://tests/artifacts/library_rear_road_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_REAR_ROAD ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
