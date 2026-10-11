extends "res://tests/LibraryUpperPlanV110.gd"
const Remote=preload("res://world/visual_campus/LibraryRemoteCore.gd")
func rp(x:float,y:float,z:float)->Vector3:
	var p=Remote.point(Vector3(x,y,z));return wp(p.x,p.y,p.z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false)
	var route:Array=[]
	for p in [[5,0,2.35],[1.02,0,2.35]]:route.append([rp(p[0],p[1],p[2]),"ground approach "+str(p)])
	for i in 4:
		var y:float=Remote.LEVELS[i];var top:float=Remote.LEVELS[i+1];var half:float=(y+top)/2
		for p in [[-1.02,y,2.35],[-1.02,half,-2.35],[1.02,half,-2.35],[1.02,top,2.35],[5,top,2.35]]:route.append([rp(p[0],p[1],p[2]),"registered remote ascent "+str(p)])
		if i>=1:
			for p in [[268,390],[268,210],[220,210],[185,210],[268,210],[268,390]]:route.append([pp(p[0],p[1],top),"paired WC cross aisle "+str(top)+str(p)])
			route.append([rp(5,top,2.35),"return to stair entry "+str(top)])
		route.append([rp(1.02,top,2.35),"upper stair return "+str(top)])
	for i in range(3,-1,-1):
		var y:float=Remote.LEVELS[i];var top:float=Remote.LEVELS[i+1];var half:float=(y+top)/2
		for p in [[1.02,half,-2.35],[-1.02,half,-2.35],[-1.02,y,2.35],[1.02,y,2.35]]:route.append([rp(p[0],p[1],p[2]),"registered remote descent "+str(p)])
	for p in [[5,0,2.35],[5,0,0]]:route.append([rp(p[0],p[1],p[2]),"lower exit "+str(p)])
	for p in [Vector3(-32.5,0,-18.8),Vector3(-32.5,0,-23.8),Vector3(-30,.36,-22.4),Vector3(-30,.48,-27),Vector3(-30,0,-32),Vector3(-30,.48,-27),Vector3(-30,0,-19),Vector3(-32.5,0,-8)]:route.append([wp(p.x,p.y,p.z),"lower WC to rear porch "+str(p)])
	await fixture(rp(5,.3,5),route)
	if not failures.is_empty():
		var target=route[legs.size()-1][0];var q=PhysicsRayQueryParameters3D.create(world.player.global_position+Vector3.UP*.9,target+Vector3.UP*.9);q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q)
		if not hit.is_empty():print("OBSTRUCTION ",hit.collider.get_path()," ",hit.position)
		var shape:=SphereShape3D.new();shape.radius=.55
		var sq:=PhysicsShapeQueryParameters3D.new();sq.shape=shape;sq.transform=Transform3D(Basis.IDENTITY,world.player.global_position+Vector3.UP*.7);sq.exclude=[world.player.get_rid()]
		for contact in world.get_world_3d().direct_space_state.intersect_shape(sq,12):print("NEAR_CONTACT ",contact.collider.get_path())
	var checks:Array=[]
	for y in [4.4,8.8,12.8,16.8]:
		var q=PhysicsRayQueryParameters3D.create(rp(0,y+.25,0),rp(0,y-.25,0));q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var ok:bool=hit.is_empty();checks.append({"case":"registered shaft open "+str(y),"valid":ok});if not ok:failures.append(checks[-1].case)
	var report={"version":world.data.version,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":1,"scope":"Registered remote coreG-5F,paired upperWC frontages,lowerWC torearporch;wholecampus remains active"}
	FileAccess.open("res://tests/artifacts/library_remote_v112.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_REMOTE_V112 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
