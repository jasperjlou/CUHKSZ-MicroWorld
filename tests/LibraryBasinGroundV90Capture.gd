extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-shore-v90",Vector3(13,4.05,-328),Vector3(23,3.8,-260))
	await capture("library-basin-v90",Vector3(6,15,-338),Vector3(36,2.6,-296))
	await capture("teaching-c-crossing-v90",Vector3(-27,4.0,-279.5),Vector3(-45,4,-300))
	var depths:Array=[]
	for p:Vector2 in [Vector2(27,-294),Vector2(27,-308),Vector2(41,-319),Vector2(27,-275)]:
		var query:=PhysicsRayQueryParameters3D.create(Vector3(p.x,4,p.y),Vector3(p.x,0,p.y),1)
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(query)
		var expected:float=2.47 if p.y==-275 else 1.54
		var valid:bool=not hit.is_empty() and absf(float(hit.position.y)-expected)<.03
		depths.append({"point":[p.x,p.y],"expected_floor":expected,"actual_y":float(hit.position.y) if not hit.is_empty() else -99,"valid":valid})
		if not valid:failures.append("basin or bridge floor "+str(p))
	await fixture(Vector3(15,2.54,-329),[
		[Vector3(15,2.24,-302),"west shore along former floating crossing"],
		[Vector3(15,2.24,-275),"main bridge west approach"],
		[Vector3(40,2.24,-275),"main bridge across actual basin"],
		[Vector3(40,2.24,-305),"library east promenade"],
		[Vector3(40,2.24,-275),"east promenade return"],
		[Vector3(15,2.24,-275),"bridge west return"],
		[Vector3(12,2.24,-279.5),"teaching transverse path turn"],
		[Vector3(-38,2.24,-279.5),"teaching C hardscape interface"],
		[Vector3(12,2.24,-279.5),"transverse return"],
		[Vector3(15,2.24,-329),"shore return toward student centre"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"floor_probes":depths,"fixtures":1,"no_teleport_within_each_fixture":true,"scope":"V90 actual basin/retained bridge,stone shore and teaching transverse ground;site fidelity partial"}
	FileAccess.open("res://tests/artifacts/library_basin_ground_v90.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_BASIN_V90 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
