extends "res://tests/LibraryStudyPodsV101Capture.gd"
const G=preload("res://world/visual_campus/LibraryGroundStair.gd")
func gp(x:float,y:float,z:float)->Vector3:
	var p=G.point(Vector3(x,y,z));return wp(p.x,p.y,p.z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-ground-v103-final-tiers",gp(4,1.8,-3.5),gp(4,1.5,3))
	await capture("library-ground-v103-final-stair",gp(-.2,1.8,-2.5),gp(0,3.3,7))
	await capture("library-ground-v103-final-opening",gp(-3.4,6.2,9),gp(0,3.8,7))
	var route:Array=[]
	route.append([gp(0,4.4,11.1),"final stair ascent"])
	route.append([wp(12,4.4,-7),"final 2F connection"])
	route.append([gp(0,4.4,11.1),"final 2F return"])
	route.append([gp(0,0,-1),"final stair descent"])
	route.append([wp(2,0,4.5),"front of diagonal rooms"])
	route.append([wp(10.85,0,-2.49),"diagonal public aisle"])
	for p in [Vector3(12,0,-5),Vector3(18,0,-5),Vector3(18,0,0),Vector3(16,0,1),Vector3(30,0,1),Vector3(30,0,-6),Vector3(25.04,0,-9.06),Vector3(22.78,0,-11.32),Vector3(25.04,0,-9.06),Vector3(30,0,-6),Vector3(27.27,0,-4.17),Vector3(25.574,0,-2.474),Vector3(27.27,0,-4.17),Vector3(25.67,0,-6.17),Vector3(23.974,0,-4.474),Vector3(25.67,0,-6.17),Vector3(30,0,-6),Vector3(30,0,1),Vector3(16,0,1),Vector3(10,0,3),Vector3(0,0,12),Vector3(-18,0,10)]:
		route.append([wp(p.x,p.y,p.z),"right wing and return "+str(p)])
	await fixture(gp(0,.3,-1),route)
	var checks:Array=[]
	for s in [[gp(0,4,8),gp(0,5.2,8),false,"upper opening clear"],[gp(0,4.95,8),gp(2,4.95,8),true,"upper guard solid"],[wp(0,4.8,5),wp(0,4,5),true,"old opening filled"],[gp(5,3,4.7),gp(5,0,4.7),true,"low timber tier"]]:
		var q=PhysicsRayQueryParameters3D.create(s[0],s[1]);q.exclude=[world.player.get_rid()]
		var h=world.get_world_3d().direct_space_state.intersect_ray(q)
		var valid:bool=(not h.is_empty())==s[2]
		if s[3]=="low timber tier" and not h.is_empty():valid=valid and absf(h.position.y-2.24-1.68)<.08
		checks.append({"case":s[3],"valid":valid})
		if not valid:failures.append(s[3])
	var report={"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":1,"no_teleport_within_fixture":true,"scope":"G seating and narrow stair; single rooms and diagonal wing. Exact metre registration remains fitted."}
	FileAccess.open("res://tests/artifacts/library_ground_stair_v103_final.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_GROUND_STAIR ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
