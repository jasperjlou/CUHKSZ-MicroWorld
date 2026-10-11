extends "res://tests/LibraryDiagonalV107Capture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false)
	var route:Array=[]
	for p:Vector3 in [Vector3(3,0,-1.5),Vector3(3,0,-6.2)]:route.append([cp(p.x,p.y,p.z),"clear printer approach "+str(p)])
	for i in 5:
		var y:float=Diagonal.LEVELS[i];var top:float=Diagonal.LEVELS[i+1];var half:float=(y+top)/2
		for p:Vector3 in [Vector3(-5.7,y,-6.2),Vector3(-5.7,half,2),Vector3(-3,half,2),Vector3(-3,top,-6.2),Vector3(3,top,-6.2),Vector3(3,top,2),Vector3(3,top,-6.2)]:route.append([cp(p.x,p.y,p.z),"registered diagonal ascent "+str(p)])
	for p in [Vector3(-3,20.8,-6.2),Vector3(-3,18.8,2),Vector3(-5.7,18.8,2),Vector3(-5.7,16.8,-6.2),Vector3(3,16.8,-6.2),Vector3(6.5,16.8,1)]:route.append([cp(p.x,p.y,p.z),"diagonal descent5F "+str(p)])
	route.append([wp(10,16.8,16),"5F diagonal wing exit"])
	await fixture(cp(3,.3,1),route)
	var report={"version":world.data.version,"physical_legs":legs,"failures":failures,"fixtures":1,"geometry_changed":false,"scope":"Remainder of diagonal core after replacing printer-intersecting target;initial left-core evidence retained"}
	FileAccess.open("res://tests/artifacts/library_map_cores_v109_final.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_MAP_CORES_FINAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
