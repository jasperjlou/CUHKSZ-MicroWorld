extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("hall-roof-final-v70",Vector3(153,54,58),Vector3(66,17,-1))
	await capture("hall-street-final-v70",Vector3(100,9,51),Vector3(66,14,0))
	await capture("hall-seating-final-v70",Vector3(92,12,-2),Vector3(55,15,-1))
	await capture("hall-lake-glass-final-v70",Vector3(122,13,29),Vector3(85,15,-1))
	var route:Array=[
		[Vector3(91,8.8,-11.5),"front aisle bypasses stair well"],[Vector3(79,8.8,-11.5),"far end of hall stair well"],[Vector3(79,8.8,-.9),"centre stepped aisle entry"],
		[Vector3(49.5,14.2,-.9),"centre aisle ascent"],[Vector3(49.5,14.2,9.8),"rear aisle return"],[Vector3(79,8.8,9.8),"near aisle descent"],
		[Vector3(80,8.8,12),"hall landing return"],[Vector3(85,8.8,12),"upper stair turn"],[Vector3(85,4.4,-10),"hall to foyer descent"],
		[Vector3(90,4.4,-10),"lower stair return"],[Vector3(90,0,12),"foyer to ground descent"],[Vector3(86,0,12),"ground rail clearance"],
		[Vector3(82,0,10),"street exit approach"],[Vector3(82,0,17),"street exit"]]
	await fixture(Vector3(91,9.1,-.9),route)
	var checks:Array=[]
	for sample:Array in [[Vector3(45,26,0),Vector3(45,23,0),true,"higher roof end"],[Vector3(96,23,0),Vector3(96,19.5,0),true,"lower roof end"],[Vector3(50,26,-10),Vector3(50,22,-10),false,"skylight actually cuts roof"],[Vector3(85,12,0),Vector3(85,8,0),false,"upper stair well open"],[Vector3(94,18,-1),Vector3(100,18,-1),true,"inclined lake glazing collision"]]:
		var q:=PhysicsRayQueryParameters3D.create(sample[0],sample[1]);q.exclude=[world.player.get_rid()]
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=(not hit.is_empty())==sample[2]
		checks.append({"case":sample[3],"valid":valid})
		if not valid:failures.append(sample[3])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"scope":"changed hall public section only;fitted seating/levels,no capacity or whole-campus claim","no_teleport_within_fixture":true}
	FileAccess.open("res://tests/artifacts/assembly_section_finish_v70.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ASSEMBLY_SECTION ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
