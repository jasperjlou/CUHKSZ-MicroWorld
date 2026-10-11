extends "res://tests/ZhangTiersV133.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true;building=world.builder.buildings.zhang_lingbin
	if DisplayServer.get_name()!="headless":
		await capture("zhang-plan-v134-overview",pos(0,70,135),pos(0,0))
		await capture("zhang-plan-v134-roof",pos(-32,26,22),pos(-18,-10,12.4))
		await capture("zhang-plan-v134-interior",pos(-24.4,8,6.6),pos(-24.4,-18,6.5))
		await capture("zhang-plan-v134-bridge",pos(-21.5,29,10.3),pos(-21.5,13,10.3))
		await capture("zhang-plan-v134-notch",pos(-4,-4,8),pos(-21,-4,8))
		FileAccess.open("res://tests/artifacts/zhang_plan_v134_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	var route:Array=[]
	# One continuous route from first photo gallery, through both low-wing levels,
	# onto the stepped roof and back down the rear core. No teleport between targets.
	for p:Vector3 in [Vector3(-21.5,4.925,24),Vector3(-21.5,4.925,14),Vector3(-24.4,4.925,14),Vector3(-24.4,4.925,-12),Vector3(-24.4,4.925,-20),Vector3(-21.5,4.925,-20),Vector3(-21.5,4.925,-26.6),Vector3(-21.65,6.775,-39.1),Vector3(-19.15,6.775,-39.1),Vector3(-19.15,8.625,-26.6),Vector3(-21.5,8.625,-26.6),Vector3(-21.5,8.625,-20),Vector3(-24.4,8.625,-20),Vector3(-24.4,8.625,14),Vector3(-21.5,8.625,14),Vector3(-21.5,8.625,24),Vector3(-21.5,8.625,41.24),Vector3(-21.5,8.625,14),Vector3(-24.4,8.625,14),Vector3(-24.4,8.625,-20),Vector3(-21.5,8.625,-20),Vector3(-21.5,8.625,-26.6),Vector3(-21.65,10.475,-39.1),Vector3(-19.15,10.475,-39.1),Vector3(-19.15,12.325,-26.6),Vector3(-21.5,12.325,-26.6),Vector3(-21.5,12.325,-23),Vector3(-24.4,12.325,-23),Vector3(-32.5,12.325,-22),Vector3(-32.5,12.325,14),Vector3(-24.4,12.325,14),Vector3(-15,12.325,14),Vector3(-15,12.325,1),Vector3(-24.4,12.325,1),Vector3(-24.4,12.325,-10),Vector3(-15,12.325,-10),Vector3(-17,12.325,-20),Vector3(-21.5,12.325,-23),Vector3(-21.5,12.325,-26.6),Vector3(-19.15,12.325,-26.6)]:route.append([building.to_global(p),"stepped wing "+str(p)])
	var ys:Array[float]=[0,4.925,8.625,12.325]
	for f in [2,1,0]:
		var half:float=(ys[f]+ys[f+1])/2
		for p:Vector3 in [Vector3(-19.15,half,-39.1),Vector3(-21.65,half,-39.1),Vector3(-21.65,ys[f],-26.6)]:route.append([building.to_global(p),"descent "+str(p)])
		if f>0:route.append([pos(-19.15,-26.6,ys[f]),"lower transfer "+str(f)])
	for p:Vector3 in [Vector3(-20.4,0,-26.6),Vector3(-20.4,0,-20),Vector3(0,0,-20),Vector3(0,0,-46)]:route.append([building.to_global(p),"rear exit "+str(p)])
	await fixture(pos(-21.5,41.24,5.225),route)
	probe("roof notch stays open",pos(-17,-4,13),pos(-17,-4,11.8),false)
	probe("notch lower floor also open",pos(-17,-4,9),pos(-17,-4,8.0),false)
	probe("recess wall is solid",pos(-22,-4,6.7),pos(-20,-4,6.7),true)
	probe("front upper door clear",pos(-21.5,17.5,10.2),pos(-21.5,15,10.2),false)
	probe("front lower glazing solid",pos(-29,17.5,6.6),pos(-29,15,6.6),true)
	probe("notch roof edge guarded",pos(-22,-4,12.9),pos(-20,-4,12.9),true)
	FileAccess.open("res://tests/artifacts/zhang_plan_v134_physics.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":1,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
