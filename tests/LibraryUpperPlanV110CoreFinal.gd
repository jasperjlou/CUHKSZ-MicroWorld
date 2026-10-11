extends "res://tests/LibraryUpperPlanV110.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false)
	var route:Array=[]
	for p in [[860,765],[855,820]]:route.append([pp(p[0],p[1],20.8),"6F restored core-side aisle "+str(p)])
	for p in [Vector3(6.5,20.8,3.4),Vector3(3,20.8,3.4),Vector3(3,20.8,-6.2),Vector3(-3,20.8,-6.2),Vector3(-3,18.8,2),Vector3(-5.7,18.8,2),Vector3(-5.7,16.8,-6.2),Vector3(3,16.8,-6.2),Vector3(6.5,16.8,1)]:route.append([cp(p.x,p.y,p.z),"corrected6F access and5F descent "+str(p)])
	await fixture(pp(865,715,21.1),route)
	if not failures.is_empty():
		var player=world.player;var q=PhysicsRayQueryParameters3D.create(player.global_position+Vector3.UP*.9,route[legs.size()-1][0]+Vector3.UP*.9);q.exclude=[player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q)
		if not hit.is_empty():print("OBSTRUCTION ",hit.collider.get_path()," ",hit.position)
	var report={"version":world.data.version,"physical_legs":legs,"failures":failures,"fixtures":1,"scope":"Corrected602-605 locations freecore-sideaisle;bridgeexit todiagonalcoreand5F"}
	FileAccess.open("res://tests/artifacts/library_upper_plan_v110_core_connected.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_UPPER_CORE_FINAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
