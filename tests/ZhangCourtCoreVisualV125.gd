extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var b:Node3D=world.builder.buildings.zhang_lingbin
	if DisplayServer.get_name()!="headless":
		await capture("zhang-core-v125-final-court",b.to_global(Vector3(-9,20,24)),b.to_global(Vector3(-21,9,-12)))
		await capture("zhang-core-v125-final-entry",b.to_global(Vector3(-18,2.0,-16)),b.to_global(Vector3(-20.4,2.4,-29)))
		await capture("zhang-core-v125-final-stair",b.to_global(Vector3(-20.4,6.6,-26.4)),b.to_global(Vector3(-20.4,7.8,-37)))
		await capture("zhang-core-v125-final-gallery",b.to_global(Vector3(-21.5,10.3,23)),b.to_global(Vector3(-21.5,9,42)))
		FileAccess.open("res://tests/artifacts/zhang_core_v125_final_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	var route:Array=[]
	for pair:Array in [[Vector3(0,0,-46),"rear perimeter"],[Vector3(0,0,-20),"rear undercroft to core path"],[Vector3(-20.4,0,-20),"stair vestibule approach"],[Vector3(-20.4,0,-26.6),"stair vestibule door"],[Vector3(-21.65,0,-27.5),"first flight foot"]]:route.append([b.to_global(pair[0]),pair[1]])
	var ys:Array[float]=[0,4.925,8.625,12.325,16.025]
	for f in 4:
		var y:float=ys[f];var upper:float=ys[f+1];var half:float=(y+upper)/2
		for pair:Array in [[Vector3(-21.65,half,-39.1),"out flight"],[Vector3(-19.15,half,-39.1),"half landing"],[Vector3(-19.15,upper,-26.6),"return flight"]]:route.append([b.to_global(pair[0]),str(f+1)+" "+pair[1]])
		if f<3:route.append([b.to_global(Vector3(-21.65,upper,-26.6)),str(f+1)+" upper landing transfer"])
	for pair:Array in [[Vector3(-20.4,16.025,-23),"top return doorway"],[Vector3(-21.5,16.025,-23),"top corner gallery"],[Vector3(-21.5,16.025,28),"top court gallery end"],[Vector3(-21.5,16.025,-23),"top court gallery return"],[Vector3(-20.4,16.025,-23),"core return doorway"],[Vector3(-19.15,16.025,-26.6),"top descending head"]]:route.append([b.to_global(pair[0]),pair[1]])
	for f in [3,2,1,0]:
		var y:float=ys[f];var upper:float=ys[f+1];var half:float=(y+upper)/2
		for pair:Array in [[Vector3(-19.15,half,-39.1),"return flight down"],[Vector3(-21.65,half,-39.1),"half landing down"],[Vector3(-21.65,y,-26.6),"out flight down"]]:route.append([b.to_global(pair[0]),str(f+1)+" "+pair[1]])
		if f>0:route.append([b.to_global(Vector3(-19.15,y,-26.6)),str(f)+" lower landing transfer"])
	for pair:Array in [[Vector3(-20.4,0,-26.6),"ground landing"],[Vector3(-20.4,0,-20),"ground vestibule exit"],[Vector3(0,0,-20),"court path return"],[Vector3(0,0,-46),"rear undercroft exit"]]:route.append([b.to_global(pair[0]),pair[1]])
	await fixture(b.to_global(Vector3(0,.3,-48.5)),route)
	FileAccess.open("res://tests/artifacts/zhang_core_v125_landing.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"failures":failures,"physical_legs":legs,"fixtures":1,"scope":"Rear courtyard core four occupied levels and both photo-front gallery joins. Fitted metric plan, not entire D building completion."},"\t"))
	quit(0 if failures.is_empty() else 1)
