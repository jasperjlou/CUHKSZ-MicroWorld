extends "res://tests/LibraryStudyPodsV101Capture.gd"
const Diagonal=preload("res://world/visual_campus/LibraryDiagonalCore.gd")
func cp(x:float,y:float,z:float)->Vector3:
	var p=Diagonal.point(Vector3(x,y,z));return wp(p.x,p.y,p.z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-diagonal-v107-ground",cp(6,1.8,-5.0),cp(-1,1.7,4.6))
	await capture("library-diagonal-v107-stair",cp(1,1.8,-6.2),cp(-5.7,2,0))
	await capture("library-diagonal-v107-second",wp(5,6.2,10),wp(-3,6.1,16))
	await capture("library-diagonal-v107-lift",cp(3.9,1.8,.7),cp(.15,1.5,4.25))
	var route:Array=[]
	for p in [Vector3(7,0,-3),Vector3(3,0,-6.2),Vector3(-3,0,-6.2),Vector3(-5.7,0,-6.2),Vector3(-5.7,2.2,2),Vector3(-3,2.2,2),Vector3(-3,4.4,-6.2),Vector3(3,4.4,-6.2)]:route.append([cp(p.x,p.y,p.z),"G to2F "+str(p)])
	route.append([wp(0,4.4,9),"core lobby to public2F stair foot"])
	route.append([wp(11.2,8.8,-2.2),"public2F to3F stair remains clear"])
	route.append([wp(0,4.4,9),"public stair return to2F"])
	route.append([cp(3,4.4,-6.2),"2F diagonal lobby return"])
	for i in range(1,5):
		var y:float=Diagonal.LEVELS[i];var top:float=Diagonal.LEVELS[i+1];var half:float=(y+top)/2
		for p in [Vector3(-5.7,y,-6.2),Vector3(-5.7,half,2),Vector3(-3,half,2),Vector3(-3,top,-6.2),Vector3(3,top,-6.2),Vector3(3,top,2.0),Vector3(3,top,-6.2)]:route.append([cp(p.x,p.y,p.z),"core ascent/lobby "+str(p)])
	for i in range(5,0,-1):
		var y:float=Diagonal.LEVELS[i];var below:float=Diagonal.LEVELS[i-1];var half:float=(y+below)/2
		for p in [Vector3(-3,y,-6.2),Vector3(-3,half,2),Vector3(-5.7,half,2),Vector3(-5.7,below,-6.2),Vector3(3,below,-6.2)]:route.append([cp(p.x,p.y,p.z),"core descent "+str(p)])
	for p in [Vector3(3,0,3.8),Vector3(-4.55,0,3.8),Vector3(3,0,3.8),Vector3(5,0,-3),Vector3(8,0,-3)]:route.append([cp(p.x,p.y,p.z),"G lift/WC lobby andpublic return "+str(p)])
	route.append([wp(10,0,3),"lower public wing return"])
	await fixture(wp(10,.3,3),route)
	var checks:Array=[]
	for s in [[cp(-5.7,4.8,0),cp(-5.7,3.9,0),false,"stair shaft floor opening"],[cp(3,4.8,0),cp(3,4.0,0),true,"second floor public lobby slab"],[cp(0,1.6,3.5),cp(0,1.6,5),true,"closed lift enclosure"],[cp(-4,1.6,6.5),cp(-4,1.6,8),true,"core outside return wall"]]:
		var q=PhysicsRayQueryParameters3D.create(s[0],s[1]);q.exclude=[world.player.get_rid()]
		var h=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=(not h.is_empty())==s[2]
		checks.append({"case":s[3],"valid":valid})
		if not valid:failures.append(s[3])
	var report={"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Registered diagonal coreG-6F roundtrip,public2F3F stair,groundlift/WCfrontage;other upperwing exits not audited"}
	FileAccess.open("res://tests/artifacts/library_diagonal_v107.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_DIAGONAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
