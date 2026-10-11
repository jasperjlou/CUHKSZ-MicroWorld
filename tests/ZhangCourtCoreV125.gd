extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var b:Node3D=world.builder.buildings.zhang_lingbin
	if DisplayServer.get_name()!="headless":
		await capture("zhang-core-v125-court",b.to_global(Vector3(9,17,-11)),b.to_global(Vector3(-19,8,-18)))
		await capture("zhang-core-v125-entry",b.to_global(Vector3(-3,2.0,-17)),b.to_global(Vector3(-12,3.5,-30)))
		await capture("zhang-core-v125-stair",b.to_global(Vector3(-12.2,6.6,-26.4)),b.to_global(Vector3(-12.2,7.8,-37)))
		await capture("zhang-core-v125-gallery",b.to_global(Vector3(-21.5,10.3,23)),b.to_global(Vector3(-21.5,9,42)))
		FileAccess.open("res://tests/artifacts/zhang_core_v125_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	var route:Array=[]
	for pair:Array in [[Vector3(0,0,-46),"rear perimeter"],[Vector3(0,0,-22),"rear undercroft to core path"],[Vector3(-12,0,-22),"stair vestibule approach"],[Vector3(-12,0,-26.6),"stair vestibule door"],[Vector3(-14.2,0,-27.5),"first flight foot"]]:route.append([b.to_global(pair[0]),pair[1]])
	var ys:Array[float]=[0,4.925,8.625,12.325,16.025]
	for f in 4:
		var y:float=ys[f];var upper:float=ys[f+1];var half:float=(y+upper)/2
		for pair:Array in [[Vector3(-14.2,half,-39.1),"out flight"],[Vector3(-10.2,half,-39.1),"half landing"],[Vector3(-10.2,upper,-26.6),"return flight"]]:route.append([b.to_global(pair[0]),str(f+1)+" "+pair[1]])
		if f<3:route.append([b.to_global(Vector3(-14.2,upper,-26.6)),str(f+1)+" upper landing transfer"])
	for pair:Array in [[Vector3(-12,16.025,-23),"top return doorway"],[Vector3(-21.5,16.025,-23),"top corner gallery"],[Vector3(-21.5,16.025,28),"top court gallery end"],[Vector3(-21.5,16.025,-23),"top court gallery return"],[Vector3(-12,16.025,-23),"core return doorway"],[Vector3(-10.2,16.025,-26.6),"top descending head"]]:route.append([b.to_global(pair[0]),pair[1]])
	for f in [3,2,1,0]:
		var y:float=ys[f];var upper:float=ys[f+1];var half:float=(y+upper)/2
		for pair:Array in [[Vector3(-10.2,half,-39.1),"return flight down"],[Vector3(-14.2,half,-39.1),"half landing down"],[Vector3(-14.2,y,-26.6),"out flight down"]]:route.append([b.to_global(pair[0]),str(f+1)+" "+pair[1]])
		if f>0:route.append([b.to_global(Vector3(-10.2,y,-26.6)),str(f)+" lower landing transfer"])
	for pair:Array in [[Vector3(-12,0,-26.6),"ground landing"],[Vector3(-12,0,-22),"ground vestibule exit"],[Vector3(0,0,-22),"court path return"],[Vector3(0,0,-46),"rear undercroft exit"]]:route.append([b.to_global(pair[0]),pair[1]])
	await fixture(b.to_global(Vector3(0,.3,-48.5)),route)
	# Existing front external stair is the independent start for both gallery connections.
	route=[]
	for pair:Array in [[Vector3(-21.5,4.925,41.24),"front first gallery mouth"],[Vector3(-21.5,4.925,-23),"first court gallery"],[Vector3(-12,4.925,-23),"first rear doorway"],[Vector3(-14.2,4.925,-26.6),"second floor stair foot"],[Vector3(-14.2,6.775,-39.1),"second stair out"],[Vector3(-10.2,6.775,-39.1),"second half transfer"],[Vector3(-10.2,8.625,-26.6),"second stair head"],[Vector3(-12,8.625,-23),"second return doorway"],[Vector3(-21.5,8.625,-23),"second court gallery"],[Vector3(-21.5,8.625,41.24),"second photo gallery join"],[Vector3(-15,8.625,44.6),"second photo gallery forward"],[Vector3(-21.5,8.625,41.24),"second photo gallery return"]]:route.append([b.to_global(pair[0]),pair[1]])
	await fixture(b.to_global(Vector3(-21.5,5.225,44.6)),route)
	FileAccess.open("res://tests/artifacts/zhang_core_v125.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"failures":failures,"physical_legs":legs,"fixtures":2,"scope":"Rear courtyard core four occupied levels and both photo-front gallery joins. Fitted metric plan, not entire D building completion."},"\t"))
	quit(0 if failures.is_empty() else 1)
