extends "res://tests/CardBankRoomV130.gd"
var building:Node3D
func pos(x:float,z:float,y:float=0)->Vector3:return building.to_global(Vector3(x,y,z))
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	building=world.builder.buildings.zhang_lingbin
	if DisplayServer.get_name()!="headless":
		await capture("zhang-tiers-v133-overview",pos(0,70,135),pos(0,0))
		await capture("zhang-tiers-v133-low-roof",pos(-30,32,16),pos(-28,-20,13))
		await capture("zhang-tiers-v133-court",pos(-8,16,3),pos(-24,-8,12))
		await capture("zhang-tiers-v133-upper-core",pos(-21,-19,21.2),pos(-20.4,-31,21.3))
		FileAccess.open("res://tests/artifacts/zhang_tiers_v133_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	var route:Array=[]
	for p:Vector3 in [Vector3(0,0,-46),Vector3(0,0,-20),Vector3(-20.4,0,-20),Vector3(-20.4,0,-26.6),Vector3(-21.65,0,-27.5)]:route.append([building.to_global(p),"ground approach "+str(p)])
	var ys:Array[float]=[0,4.925,8.625,12.325,16.025,19.725]
	for f in 5:
		var upper:float=ys[f+1];var half:float=(ys[f]+upper)/2
		for p:Vector3 in [Vector3(-21.65,half,-39.1),Vector3(-19.15,half,-39.1),Vector3(-19.15,upper,-26.6)]:route.append([building.to_global(p),str(f+1)+" ascent "+str(p)])
		if f==2:
			for p:Vector3 in [Vector3(-21.5,upper,-26.6),Vector3(-21.5,upper,-20),Vector3(-21.5,upper,28),Vector3(-24.4,upper,28),Vector3(-24.4,upper,-17),Vector3(-32.8,upper,-17),Vector3(-32.8,upper,28),Vector3(-24.4,upper,28),Vector3(-21.5,upper,28),Vector3(-21.5,upper,-26.6)]:route.append([building.to_global(p),"low roof loop "+str(p)])
		elif f<4:route.append([pos(-21.65,-26.6,upper),"upper transfer "+str(f)])
	for p:Vector3 in [Vector3(-21.5,19.725,-26.6),Vector3(-21.5,19.725,-23),Vector3(-21.5,19.725,-26.6),Vector3(-19.15,19.725,-26.6)]:route.append([building.to_global(p),"new upper landing "+str(p)])
	for f in [4,3,2,1,0]:
		var half:float=(ys[f]+ys[f+1])/2
		for p:Vector3 in [Vector3(-19.15,half,-39.1),Vector3(-21.65,half,-39.1),Vector3(-21.65,ys[f],-26.6)]:route.append([building.to_global(p),str(f+1)+" descent "+str(p)])
		if f>0:route.append([pos(-19.15,-26.6,ys[f]),"lower transfer "+str(f)])
	for p:Vector3 in [Vector3(-20.4,0,-26.6),Vector3(-20.4,0,-20),Vector3(0,0,-20),Vector3(0,0,-46)]:route.append([building.to_global(p),"ground return "+str(p)])
	await fixture(pos(0,-48.5,.3),route)
	probe("former full-height side wing removed",pos(-28,0,13.2),pos(-28,0,23),false)
	probe("low roof supports walking",pos(-24.4,10,13),pos(-24.4,10,11.8),true)
	probe("low roof outer parapet solid",pos(-33,10,12.9),pos(-35,10,12.9),true)
	probe("retired upper long gallery removed",pos(-21.5,12,15.5),pos(-21.5,12,20.5),false)
	probe("tall rear roof exists",pos(-27,-35,24),pos(-27,-35,22.7),true)
	probe("new top landing end guarded",pos(-21.5,-23,20.3),pos(-21.5,-20.5,20.3),true)
	FileAccess.open("res://tests/artifacts/zhang_tiers_v133_physics.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":1,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
