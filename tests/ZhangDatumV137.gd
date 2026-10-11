extends "res://tests/CardBankRoomV130.gd"
var building:Node3D
func pos(x:float,z:float,y:float=0)->Vector3:return building.to_global(Vector3(x,y,z))
func walk(target:Vector3,label:String)->bool:
	var player:CharacterBody3D=world.player;var count:=0;var lowest:float=player.position.y
	var floor_limit:float=minf(player.position.y,target.y)-.65
	while Vector2(target.x-player.position.x,target.z-player.position.z).length()>.18 and count<1800:
		player.navigation_direction=Vector2(target.x-player.position.x,target.z-player.position.z).normalized()
		await physics_frame;count+=1;lowest=minf(lowest,player.position.y)
	player.navigation_direction=Vector2.ZERO;await frames(12)
	var distance:=Vector2(target.x-player.position.x,target.z-player.position.z).length()
	var valid:=count<1800 and distance<.40 and lowest>floor_limit and absf(player.position.y-target.y)<.4
	if not valid:failures.append(label)
	legs.append({"goal":label,"valid":valid,"frames":count,"distance":distance,"lowest_y":lowest,"floor_limit":floor_limit,"end":[player.position.x,player.position.y,player.position.z]})
	print("ZHANG_DATUM_LEG ",label," ",valid," ",player.position)
	return valid
func level_probe(label:String,x:float,z:float,y:float)->void:
	var hit:=world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(pos(x,z,y+.6),pos(x,z,y-.6),1))
	var valid:bool=not hit.is_empty() and absf(hit.position.y-pos(x,z,y).y)<.05
	checks.append({"label":label,"valid":valid,"expected_y":pos(x,z,y).y,"hit_y":hit.position.y if not hit.is_empty() else -999})
	if not valid:failures.append(label)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true;building=world.builder.buildings.zhang_lingbin
	if DisplayServer.get_name()!="headless":
		await capture("zhang-datum-v137-rear",pos(18,-59,3),pos(0,-39,-2.2))
		await capture("zhang-datum-v137-lower",pos(1,-41,-2.9),pos(-18,-21,-2.5))
		await capture("zhang-datum-v137-side",pos(-44,-39,-1),pos(-37,-6,1))
		await capture("zhang-datum-v137-overview",pos(-62,-75,55),pos(0,-6,1))
		await capture("zhang-datum-v137-bridge",pos(-21.5,30,6.6),pos(-21.5,13,5.3))
		FileAccess.open("res://tests/artifacts/zhang_datum_v137_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	var route:Array=[]
	for p:Vector3 in [Vector3(3,0,35),Vector3(3,0,25),Vector3(-21.5,.125,20),Vector3(-21.5,.125,15),Vector3(-24.4,.125,12),Vector3(-24.4,.125,-20),Vector3(-21.5,.125,-26.6),Vector3(-19.15,.125,-26.6),Vector3(-19.15,-2.3375,-39.1),Vector3(-21.65,-2.3375,-39.1),Vector3(-21.65,-4.8,-26.6),Vector3(-20.4,-4.8,-20),Vector3(-20.4,-4.8,-23.5),Vector3(0,-4.8,-23.5),Vector3(0,-4.8,-41.5),Vector3(0,-4.565,-48.5),Vector3(-38.5,-4.565,-48.5),Vector3(-54.5,.08,-52.48),Vector3(-56.3,.08,-52.48),Vector3(-54.5,.08,-52.48),Vector3(-38.5,-4.565,-48.5),Vector3(-38.5,-4.565,-32),Vector3(-38.5,.08,-8),Vector3(-38.5,.08,26),Vector3(-32,.08,26),Vector3(3,.08,31),Vector3(3,0,42),Vector3(3,0,49),Vector3(15,0,49),Vector3(15,0,44.49),Vector3(12,0,44.49),Vector3(-5,4.925,44.49),Vector3(-21.5,4.925,41.24),Vector3(-21.5,4.925,39.64),Vector3(-21.5,3.825,16.26),Vector3(-24.4,3.825,12),Vector3(-24.4,3.825,-20),Vector3(-20.4,3.825,-22.5),Vector3(-20.4,3.825,-26.6),Vector3(-21.65,3.825,-26.6),Vector3(-21.65,5.675,-39.1),Vector3(-19.15,5.675,-39.1),Vector3(-19.15,7.525,-26.6),Vector3(-24.4,7.525,-20),Vector3(-24.4,7.525,12),Vector3(-21.5,7.525,15),Vector3(-21.5,8.625,39.64),Vector3(-21.5,8.625,41.24),Vector3(-21.5,8.625,39.64),Vector3(-21.5,7.525,15),Vector3(-24.4,7.525,12),Vector3(-24.4,7.525,-20),Vector3(-19.15,7.525,-26.6),Vector3(-19.15,5.675,-39.1),Vector3(-21.65,5.675,-39.1),Vector3(-21.65,3.825,-26.6),Vector3(-19.15,3.825,-26.6),Vector3(-19.15,1.975,-39.1),Vector3(-21.65,1.975,-39.1),Vector3(-21.65,.125,-26.6),Vector3(-20.4,.125,-26.6),Vector3(-20.4,.125,-22.5),Vector3(-24.4,.125,-20),Vector3(-24.4,.125,12),Vector3(-21.5,.125,15),Vector3(-21.5,.125,20),Vector3(3,.08,25),Vector3(3,0,42)]:route.append([building.to_global(p),"datum loop "+str(p)])
	await fixture(pos(3,42,.3),route)
	level_probe("rear street lowered",0,-50,-4.565)
	level_probe("lower court substrate",0,-22,-4.8)
	level_probe("first platform separate from lower",-10,10,.08)
	level_probe("low roof datum",-24.4,10,7.525)
	level_probe("main roof datum",-27,-35,18.625)
	probe("core opening not capped by platform",pos(-21.65,-35,.5),pos(-21.65,-35,-.5),false)
	probe("lower rear entry is open",pos(0,-45,-3),pos(0,-42,-3),false)
	FileAccess.open("res://tests/artifacts/zhang_datum_v137_physics.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":1,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
