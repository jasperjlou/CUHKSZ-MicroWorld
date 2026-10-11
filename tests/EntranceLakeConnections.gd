extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("entrance-lake-final-v68",Vector3(177,54,51),Vector3(76,12,-20))
	await capture("entrance-spiral-final-v68",Vector3(109,12,-17),Vector3(104,3,-24))
	await capture("entrance-link-final-v68",Vector3(110,16,-26),Vector3(90,15,-23))
	var route:Array=[[Vector3(93,8.8,-31),"stair side approach"],[Vector3(93,8.8,-35),"rear stair lower landing"],[Vector3(85,8.8,-35),"rear stair toe"],[Vector3(85,13.2,-13),"upper link access stair"],[Vector3(90,13.2,-13),"curved link entry"]]
	for i in range(1,11):
		var t:float=float(i)/10
		route.append([Vector3(90+sin(t*PI)*3.8,13.2,-15-t*19),"curved link outward %02d"%i])
	route.append_array([[Vector3(91,13.2,-36),"bridge north landing"],[Vector3(109,13.2,-36),"lake tower open upper gallery"],[Vector3(91,13.2,-36),"tower return to bridge"]])
	for i in range(10,-1,-1):
		var t:float=float(i)/10
		route.append([Vector3(90+sin(t*PI)*3.8,13.2,-15-t*19),"curved link return %02d"%i])
	route.append_array([[Vector3(90,13.2,-13),"bridge south landing"],[Vector3(85,13.2,-13),"rear stair top"],[Vector3(85,8.8,-35),"rear stair descent"],[Vector3(93,8.8,-35),"rear lower landing return"],[Vector3(93,8.8,-31),"rear stair outside guard"],[Vector3(97,8.8,-31),"upper court rejoin"],[Vector3(97,8.8,-17),"upper court south aisle"],[Vector3(111,8.8,-17),"upper court crosswalk"],[Vector3(111,8.8,-24),"spiral top landing"],[Vector3(107,8.8,-24),"spiral top approach"]])
	for turn in 2:
		for i in range(1,25):
			var a:float=TAU*(1-float(i)/24)
			route.append([Vector3(104+cos(a)*3,8.8-turn*4.4-4.4*i/24,-24+sin(a)*3),"spiral down %d-%02d"%[turn,i]])
	route.append_array([[Vector3(111,0,-24),"lower spiral exit"],[Vector3(111,0,-10),"lower court under meeting box"],[Vector3(121,0,-10),"lake edge walk"],[Vector3(121,0,21),"lake walk south return"],[Vector3(98,0,21),"hall front approach"],[Vector3(70,0,21),"return to street door"]])
	await fixture(Vector3(97,9.1,-31),route)
	var checks:Array=[]
	for sample:Array in [[Vector3(104,10,-24),Vector3(104,1,-24),false,"open spiral core"],[Vector3(121,9.4,-20),Vector3(124,9.4,-20),true,"upper lake guard"],[Vector3(90,14.2,-24),Vector3(98,14.2,-24),true,"curved glass wall"],[Vector3(140,3,-10),Vector3(140,-.5,-10),false,"water has no leftover grass collider"]]:
		var q:=PhysicsRayQueryParameters3D.create(sample[0],sample[1]);q.exclude=[world.player.get_rid()]
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=(not hit.is_empty())==sample[2]
		checks.append({"case":sample[3],"valid":valid})
		if not valid:failures.append(sample[3])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":1,"no_teleport_within_fixture":true,"scope":"affected rear landing,curved link roundtrip,spiral two flights down and lake return;prior38 valid legs retained"}
	FileAccess.open("res://tests/artifacts/entrance_lake_connections_v68.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ENTRANCE_LAKE_CONNECTIONS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
