extends "res://tests/LibraryStudyPodsV101Capture.gd"
const W=preload("res://world/visual_campus/LibraryLowerRightWing.gd")
func sp(x:float,y:float,z:float)->Vector3:
	var p=W.studio_point(Vector3(x,y,z));return wp(p.x,p.y,p.z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-right-v104-final-pair",sp(0,1.8,5),sp(0,1.7,0))
	await capture("library-right-v104-final-116",wp(5,1.8,6),wp(14,1.7,5))
	await capture("library-right-v104-final-services",wp(0,1.8,12),wp(8,1.5,16))
	await capture("library-right-v104-final-exterior",wp(16,2.4,24),wp(23,2.5,15))
	var route:Array=[]
	for p in [Vector3(10,0,0),Vector3(12,0,-2.5),Vector3(14,0,-5),Vector3(16,0,-4.8),Vector3(16,0,-1),Vector3(20,0,-1),Vector3(30,0,1.5),Vector3(30,0,-6)]:route.append([wp(p.x,p.y,p.z),"round furniture/116 "+str(p)])
	for x in [-.64,.64]:
		for z in [3.2,.55,3.2]:route.append([sp(x,0,z),"shared studio x="+str(x)+" z="+str(z)])
	for p in [Vector3(30,0,-6),Vector3(25.04,0,-9.06),Vector3(22.78,0,-11.32),Vector3(25.04,0,-9.06),Vector3(30,0,-6),Vector3(30,0,1.5),Vector3(20,0,-1),Vector3(16,0,-1),Vector3(16,0,-4.8),Vector3(14,0,-5),Vector3(12,0,-2.5),Vector3(10,0,0),Vector3(8.6,0,4.4),Vector3(9,0,6),Vector3(5,0,9),Vector3(4,0,13),Vector3(6,0,15),Vector3(5.3,0,18),Vector3(1,0,18),Vector3(0,0,12)]:route.append([wp(p.x,p.y,p.z),"119 and116 frontage "+str(p)])
	await fixture(wp(10,.3,3),route)
	var checks:Array=[]
	for s in [[sp(-.3,1.5,0),sp(.3,1.5,0),true,"single shared divider"],[sp(0,1.5,-3),sp(0,1.5,-1.2),true,"capsule rear enclosure"],[wp(17,1.5,12),wp(25,1.5,12),false,"former glass and pavilion wall cleared inside116"],[wp(8,1.5,6),wp(14,1.5,6),true,"116 closed collection frontage"]]:
		var q=PhysicsRayQueryParameters3D.create(s[0],s[1]);q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=not hit.is_empty() if s[2] else hit.is_empty()
		checks.append({"case":s[3],"valid":valid})
		if not valid:failures.append(s[3])
	var report={"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":1,"scope":"Shared117/118,116publicfrontage and119connection;wholecampus registration still fitted"}
	FileAccess.open("res://tests/artifacts/library_right_wing_v104_final.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_RIGHT_WING ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
