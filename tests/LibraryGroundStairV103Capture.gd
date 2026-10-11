extends "res://tests/LibraryStudyPodsV101Capture.gd"
const G=preload("res://world/visual_campus/LibraryGroundStair.gd")
func gp(x:float,y:float,z:float)->Vector3:
	var p=G.point(Vector3(x,y,z));return wp(p.x,p.y,p.z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	for shot in [["tiers",Vector3(-8,1.8,1),Vector3(-1,1.5,-6)],["stair",Vector3(3,1.8,4),Vector3(3,2.4,-5)],["opening",Vector3(12,6.2,-4),Vector3(5,3.8,-6)],["diagonal",Vector3(14,1.8,4),Vector3(6,1.7,-2)],["119",Vector3(29,1.8,-5),Vector3(21,1.8,-13)],["round",Vector3(-3.5,1.8,1),Vector3(-7,1.7,-.65)]]:
		var a:Vector3=shot[1];var b:Vector3=shot[2]
		await capture("library-ground-v103-"+shot[0],wp(a.x,a.y,a.z),wp(b.x,b.y,b.z))
	var route:Array=[]
	for p in [Vector3(-14.7,0,-7),Vector3(-14.7,0,-9.8),Vector3(-14.7,0,-7),Vector3(-20.4,0,-7),Vector3(-20.4,0,3.6),Vector3(-10,0,3.6),Vector3(-4.2,0,2.8),Vector3(-4.2,0,-.65),Vector3(-6,0,-.65),Vector3(-4.2,0,-.65),Vector3(-4.2,0,3.7),Vector3(-6.2,0,5.6),Vector3(-4.2,0,3.7)]:
		route.append([wp(p.x,p.y,p.z),"single rounded rooms "+str(p)])
	route.append([gp(0,0,-1),"G narrow stair foot"])
	route.append([gp(0,4.4,11.1),"G narrow stair ascent"])
	route.append([wp(12,4.4,-7),"2F landing connection"])
	route.append([gp(0,4.4,11.1),"2F return"])
	route.append([gp(0,0,-1),"G narrow stair descent"])
	route.append([wp(2,0,4.5),"diagonal wing approach"])
	for i in 4:
		var c=Vector3(4.1+i*1.59,0,.3-i*1.59)
		for z in [2.8,.45,2.8]:
			var p=c+Basis(Vector3.UP,PI/4)*Vector3(0,0,z)
			route.append([wp(p.x,0,p.z),"room "+str(112+i)+" depth "+str(z)])
	for p in [Vector3(16,0,1),Vector3(30,0,1),Vector3(30,0,-6),Vector3(25.04,0,-9.06),Vector3(22.78,0,-11.32),Vector3(25.04,0,-9.06),Vector3(30,0,-6),Vector3(27.27,0,-4.17),Vector3(25.574,0,-2.474),Vector3(27.27,0,-4.17),Vector3(25.67,0,-6.17),Vector3(23.974,0,-4.474),Vector3(25.67,0,-6.17),Vector3(30,0,-6),Vector3(30,0,1),Vector3(16,0,1),Vector3(10,0,3),Vector3(0,0,12),Vector3(-18,0,10)]:
		route.append([wp(p.x,p.y,p.z),"right wing and return "+str(p)])
	await fixture(wp(-20.4,.3,-7),route)
	var checks:Array=[]
	for s in [[gp(0,4,8),gp(0,5.2,8),false,"upper opening clear"],[gp(0,4.95,8),gp(2,4.95,8),true,"upper guard solid"],[wp(0,4.8,5),wp(0,4,5),true,"old opening filled"],[gp(5,3,4.7),gp(5,0,4.7),true,"low timber tier"]]:
		var q=PhysicsRayQueryParameters3D.create(s[0],s[1]);q.exclude=[world.player.get_rid()]
		var h=world.get_world_3d().direct_space_state.intersect_ray(q)
		var valid:bool=(not h.is_empty())==s[2]
		if s[3]=="low timber tier" and not h.is_empty():valid=valid and absf(h.position.y-2.24-1.68)<.08
		checks.append({"case":s[3],"valid":valid})
		if not valid:failures.append(s[3])
	var report={"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":1,"no_teleport_within_fixture":true,"scope":"G seating and narrow stair; single rooms and diagonal wing. Exact metre registration remains fitted."}
	FileAccess.open("res://tests/artifacts/library_ground_stair_v103.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_GROUND_STAIR ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
