extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-arrival-v65",Vector3(-13,6,40),Vector3(1,6,-16))
	await capture("gate-sidewalk-v65",Vector3(-10.6,2.1,37),Vector3(-10.5,1,-2))
	await capture("gate-square-stone-v65",Vector3(-9,3,-17),Vector3(0,3.7,-44))
	await fixture(Vector3(-10.5,.3,38),[
		[Vector3(-10.5,0,12),"left tactile sidewalk between tree pits"],
		[Vector3(-10.5,0,8),"left bollard row opening"],
		[Vector3(-10.5,0,-10),"guard booth pedestrian bypass"],
		[Vector3(0,0,-20),"sidewalk joins inner stone court"],
		[Vector3(0,0,-39),"square granite to stair foot"],
		[Vector3(0,2.24,-54),"retained broad stair ascent"],
		[Vector3(0,2.24,-98),"upper central passage"],
		[Vector3(20,2.24,-98),"upper crosswalk"],
		[Vector3(17,2.24,-65),"ramp upper landing"],
		[Vector3(17,0,-34),"retained side ramp descent"],
		[Vector3(10.5,0,-20),"ramp to court return"],
		[Vector3(10.5,0,8),"right clear sidewalk"],
		[Vector3(10.5,0,12),"right bollard row opening"],
		[Vector3(10.5,0,38),"right tree-pit bypass"],
		[Vector3(2.5,0,38),"outside lane approach"],
		[Vector3(2.5,0,-10),"lane beside equipment median"],
		[Vector3(0,0,-20),"vehicle throat to inner court"],
		[Vector3(-10.5,0,-10),"court to left sidewalk return"],
		[Vector3(-10.5,0,38),"left entrance continuous return"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"fixtures":1,"no_teleport_within_fixture":true,"scope":"official vehicle-entry sidewalks, equipment bypass, inner paving and retained stair/ramp; ceremonial gate identity/bridge registration and flanking massing NOT accepted"}
	FileAccess.open("res://tests/artifacts/east_gate_sidewalks_v65.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("EAST_GATE_SIDEWALKS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
