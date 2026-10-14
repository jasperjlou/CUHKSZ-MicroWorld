extends "res://tests/LibraryLowerLevelCapture.gd"
func hp(x:float,z:float)->Vector3:return Vector3(x,world.builder.height(x,z),z)
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(20)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var route:Array=[]
	for p:Vector2 in [Vector2(101,-503.5),Vector2(107,-503.5),Vector2(112,-503.5),Vector2(118,-503.5),Vector2(118,-499),Vector2(96,-499)]:route.append([hp(p.x,p.y),"side approach/return "+str(p)])
	await fixture(hp(96,-503.5)+Vector3.UP*.3,route)
	var checks:Array=[]
	for x:float in [100.5,106,111]:
		var low:float=world.builder.height(x,-505.4)+.35
		var q=PhysicsRayQueryParameters3D.create(Vector3(x,low,-505.4),Vector3(x,low,-506.4));q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q)
		var valid:bool=not hit.is_empty()
		checks.append({"case":"retaining end prevents entering earth","x":x,"valid":valid})
		if not valid:failures.append("retaining wall "+str(x))
	root.disable_3d=false;await frames(15)
	await capture("shaw-return-v245-final-wall",Vector3(106,5.9,-499),Vector3(105,5.2,-506))
	await capture("shaw-return-v245-final-overhead",Vector3(117,16,-490),Vector3(105,5,-506))
	FileAccess.open("res://tests/artifacts/shaw_retaining_final_v245.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"checks":checks,"physical_legs":legs,"failures":failures,"scope":"Single side-approach and retaining-wall return route only;no campus-wide/camera-sweep/current-survey claim"},"\t"))
	print("SHAW_RETURN_FINAL_V245 ",JSON.stringify({"legs":legs.size(),"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
