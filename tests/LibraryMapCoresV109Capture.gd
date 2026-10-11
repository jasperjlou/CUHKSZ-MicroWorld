extends "res://tests/LibraryDiagonalV107Capture.gd"
const Core=preload("res://world/visual_campus/LibraryServiceCores.gd")
func lp(x:float,y:float,z:float)->Vector3:
	var p=Core.local_point(0,Vector3(x,y,z));return wp(p.x,p.y,p.z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-map-v109-ground",wp(9,1.8,13),cp(0,1.6,0))
	await capture("library-map-v109-left",wp(-20,1.8,5.5),lp(0,1.6,-3.8))
	await capture("library-map-v109-fourth",wp(10,14.5,14),wp(-12,14.2,12))
	await capture("library-map-v109-stair",cp(-2.8,14.5,-6.2),cp(-5.7,14.9,1.6))
	var diagonal:Array=[]
	for p:Vector3 in [Vector3(3,0,3.2),Vector3(4.3,0,1),Vector3(4.3,0,-1.5),Vector3(3,0,-6.2)]:diagonal.append([cp(p.x,p.y,p.z),"G diagonal services "+str(p)])
	for i in 5:
		var y:float=Diagonal.LEVELS[i];var top:float=Diagonal.LEVELS[i+1];var half:float=(y+top)/2
		for p:Vector3 in [Vector3(-5.7,y,-6.2),Vector3(-5.7,half,2),Vector3(-3,half,2),Vector3(-3,top,-6.2),Vector3(3,top,-6.2),Vector3(3,top,2),Vector3(3,top,-6.2)]:diagonal.append([cp(p.x,p.y,p.z),"registered diagonal ascent "+str(p)])
	for p in [Vector3(-3,20.8,-6.2),Vector3(-3,18.8,2),Vector3(-5.7,18.8,2),Vector3(-5.7,16.8,-6.2),Vector3(3,16.8,-6.2),Vector3(6.5,16.8,1)]:diagonal.append([cp(p.x,p.y,p.z),"diagonal descent5F "+str(p)])
	diagonal.append([wp(10,16.8,16),"5F diagonal wing exit"])
	await fixture(cp(3,.3,2),diagonal)
	var left:Array=[]
	left.append([lp(0,0,-3.8),"left ground door"])
	for i in 4:
		var y:float=Core.LEVELS[i];var top:float=Core.LEVELS[i+1];var half:float=(y+top)/2
		for p:Vector3 in [Vector3(-1.45,y,-3.5),Vector3(-1.45,half,3.8),Vector3(1.45,half,3.8),Vector3(1.45,top,-3.8),Vector3(6,top,-3.8),Vector3(1.45,top,-3.8)]:left.append([lp(p.x,p.y,p.z),"registered left ascent/door "+str(p)])
	for i in range(4,2,-1):
		var y:float=Core.LEVELS[i];var below:float=Core.LEVELS[i-1];var half:float=(y+below)/2
		for p:Vector3 in [Vector3(1.45,half,3.8),Vector3(-1.45,half,3.8),Vector3(-1.45,below,-3.8),Vector3(1.45,below,-3.8)]:left.append([lp(p.x,p.y,p.z),"left return3F "+str(p)])
	left.append([lp(6,8.8,-3.8),"left3F exit"])
	await fixture(lp(6,.3,-3.8),left)
	var checks:Array=[]
	for s in [[cp(-5.7,4.8,0),cp(-5.7,3.9,0),false,"resized diagonal shaft opening"],[lp(-1.45,4.8,0),lp(-1.45,3.9,0),false,"resized left shaft opening"],[wp(-2,13.4,13),wp(-2,13.4,11),true,"restored continuous4F guard"],[wp(0,13.1,13),wp(0,12.5,13),true,"slab between corrected core and atrium"]]:
		var q=PhysicsRayQueryParameters3D.create(s[0],s[1]);q.exclude=[world.player.get_rid()];var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var ok:bool=(not hit.is_empty())==s[2]
		checks.append({"case":s[3],"valid":ok});if not ok:failures.append(s[3])
	var report={"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":2,"scope":"Both resized/relocated cores,scaled shaft openings,upper exits;whole new4F outline/atrium/FabLab still pending"}
	FileAccess.open("res://tests/artifacts/library_map_cores_v109.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_MAP_CORES ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
