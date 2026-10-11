extends "res://tests/LibraryDiagonalV107Capture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-diagonal-v107-final-ground",cp(6,1.8,-5),cp(-1,1.7,4.6))
	await capture("library-diagonal-v107-final-lift",cp(3.9,1.8,.7),cp(.15,1.5,4.25))
	await capture("library-diagonal-v107-final-fourth",cp(3,14.5,1),cp(3,14.5,-7.3))
	await capture("library-diagonal-v107-final-stair",cp(-2.8,14.5,-6.1),cp(-5.7,15.2,1.6))
	var route:Array=[]
	for p in [Vector3(3,12.8,-6.2),Vector3(3,12.8,2),Vector3(3,12.8,-6.2)]:route.append([cp(p.x,p.y,p.z),"repaired4F landing/lobby "+str(p)])
	for i in range(3,5):
		var y:float=Diagonal.LEVELS[i];var top:float=Diagonal.LEVELS[i+1];var half:float=(y+top)/2
		for p in [Vector3(-5.7,y,-6.2),Vector3(-5.7,half,2),Vector3(-3,half,2),Vector3(-3,top,-6.2),Vector3(3,top,-6.2),Vector3(3,top,2),Vector3(3,top,-6.2)]:route.append([cp(p.x,p.y,p.z),"upper core ascent "+str(p)])
	for i in range(5,0,-1):
		var y:float=Diagonal.LEVELS[i];var below:float=Diagonal.LEVELS[i-1];var half:float=(y+below)/2
		for p in [Vector3(-3,y,-6.2),Vector3(-3,half,2),Vector3(-5.7,half,2),Vector3(-5.7,below,-6.2),Vector3(3,below,-6.2)]:route.append([cp(p.x,p.y,p.z),"core descent "+str(p)])
	for p in [Vector3(3,0,3.4),Vector3(-4.55,0,3.4),Vector3(3,0,3.4),Vector3(4.3,0,1),Vector3(4.3,0,-1.5),Vector3(3,0,-3),Vector3(8,0,-3)]:route.append([cp(p.x,p.y,p.z),"G WC/lift/services "+str(p)])
	route.append([wp(10,0,3),"lower reading wing return"])
	await fixture(cp(-3,13.1,-6.2),route)
	var checks:Array=[]
	for s in [[cp(-5.7,4.8,0),cp(-5.7,3.9,0),false,"stair shaft still clear"],[cp(3,4.8,0),cp(3,4,0),true,"public lobby slab"],[cp(0,1.6,2.5),cp(0,1.6,3.9),false,"lift approach no longer occupied by water station"],[wp(-2,13.35,13),wp(-2,13.35,11),false,"retired straight4F rail clear"],[cp(3,13.35,-6.5),cp(3,13.35,-8),true,"new diagonal4F guard"],[cp(3,21.35,-6.5),cp(3,21.35,-8),true,"new diagonal6F guard"]]:
		var q=PhysicsRayQueryParameters3D.create(s[0],s[1]);q.exclude=[world.player.get_rid()]
		var h=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=(not h.is_empty())==s[2]
		checks.append({"case":s[3],"valid":valid})
		if not valid:failures.append(s[3])
	var report={"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Continue initial G-to4F batch from repaired4F landing,to6F andback G;combined evidence is two fixtures,not one uninterrupted entire tour"}
	FileAccess.open("res://tests/artifacts/library_diagonal_v107_final.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_DIAGONAL_FINAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
