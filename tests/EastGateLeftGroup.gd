extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-double-towers-v67",Vector3(-48,15,75),Vector3(-55,17,-15))
	await capture("gate-left-courtyard-v67",Vector3(-57,60,48),Vector3(-57,4,-15))
	await capture("gate-left-hall-v67",Vector3(-94,5,39),Vector3(-75,10,7))
	await capture("gate-left-platform-v67",Vector3(-56,6.2,17),Vector3(-55,6,-24))
	await fixture(Vector3(-12,.3,19.5),[
		[Vector3(-12,-.36,38),"ceremonial approach to outer pavement"],
		[Vector3(-35,0,40),"outside west transition"],
		[Vector3(-80,0,40),"front walk to projecting hall"],
		[Vector3(-80,0,36.5),"hall stair toe"],
		[Vector3(-80,2.2,29),"lower wide flight"],
		[Vector3(-80,4.4,20),"upper wide flight to sheltered deck"],
		[Vector3(-56,4.4,20),"under projecting hall to courtyard approach"],
		[Vector3(-46,4.4,10),"inner tower platform"],
		[Vector3(-46,4.4,-28),"east side of open light well"],
		[Vector3(-65,4.4,-28),"rear courtyard crosswalk"],
		[Vector3(-65,4.4,-38),"outer tower side gallery"],
		[Vector3(-54,4.4,-38),"low rear bar doorway approach"],
		[Vector3(-54,4.4,-48),"rear bar public passage"],
		[Vector3(-77,4.4,-48),"rear bar outer connection"],
		[Vector3(-54,4.4,-48),"rear bar return"],
		[Vector3(-54,4.4,-56),"rear stair landing"],
		[Vector3(-54,2.24,-71),"rear stair to teaching-side grade"],
		[Vector3(-20,2.24,-71),"rear paved link to mall side"],
		[Vector3(-20,2.24,-57),"left mall walk"],
		[Vector3(0,2.24,-57),"main stair upper connection"],
		[Vector3(0,0,-39),"main stair descent"],
		[Vector3(0,0,-20),"return through main gate square"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"fixtures":1,"no_teleport_within_fixture":true,"scope":"two-high/two-low entrance-left group,front flights,public deck/light-well perimeter,rear link and mall connection;upper tower cores,full room plans and surveyed site open"}
	FileAccess.open("res://tests/artifacts/east_gate_left_group_v67.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("GATE_LEFT_GROUP ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
