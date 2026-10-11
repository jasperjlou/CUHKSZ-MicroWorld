extends "res://tests/LibraryLowerLevelCapture.gd"
## One continuous circuit visits all eight changed doorways and the surrounding aisles.
func walk(target: Vector3,label: String) -> bool:
	var player:CharacterBody3D=world.player
	var count:=0;var lowest:=player.position.y
	while Vector2(target.x-player.position.x,target.z-player.position.z).length()>.12 and count<1200:
		player.navigation_direction=Vector2(target.x-player.position.x,target.z-player.position.z).normalized()
		await physics_frame;count+=1;lowest=minf(lowest,player.position.y)
	player.navigation_direction=Vector2.ZERO;await frames(8)
	var distance:=Vector2(target.x-player.position.x,target.z-player.position.z).length()
	var valid:bool=count<1200 and distance<.35 and absf(player.position.y-target.y)<.6
	if not valid:failures.append(label)
	legs.append({"goal":label,"valid":valid,"distance":distance,"end":[player.position.x,player.position.y,player.position.z],"lowest_y":lowest})
	print("POD_LEG ",label," ",valid)
	return valid

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-pods-v101-front",wp(-19,1.8,4.1),wp(-29,1.8,1))
	await capture("library-pods-v101-corner",wp(-35.4,1.8,4.1),wp(-30,1.9,0))
	await capture("library-pods-v101-inside",wp(-28.4,1.8,1.7),wp(-31,1.6,-1))
	await capture("library-pods-v101-small",wp(-15,1.8,-6.7),wp(-7.9,1.8,-13.2))
	var route:Array=[]
	route.append([wp(-18,0,4.1),"public hall to clear front cross aisle"])
	for x in [-28.13,-26.87]:
		route.append([wp(x,0,4.1),"101-104 front door alignment"])
		route.append([wp(x,0,1.5),"front room enter "+str(x)])
		route.append([wp(x,0,4.1),"front room exit "+str(x)])
	route.append([wp(-35,0,4.1),"rounded corner outer aisle"])
	route.append([wp(-35,0,-3),"window-side island passage"])
	route.append([wp(-35,0,4.1),"window-side return"])
	route.append([wp(-19,0,4.1),"front cross aisle return"])
	route.append([wp(-19,0,-8.3),"right side bypass to rear cross aisle"])
	for x in [-28.13,-26.87]:
		route.append([wp(x,0,-8.3),"101-102 rear door alignment"])
		route.append([wp(x,0,-5.1),"rear room enter "+str(x)])
		route.append([wp(x,0,-8.3),"rear room exit "+str(x)])
	route.append([wp(-32.5,0,-8.3),"remote core public aisle retained"])
	route.append([wp(-14,0,-8),"central cross aisle"])
	for x in [-8.53,-7.27]:
		route.append([wp(x,0,-7.6),"108-109 front door alignment"])
		route.append([wp(x,0,-10.3),"small front enter "+str(x)])
		route.append([wp(x,0,-7.6),"small front exit "+str(x)])
	route.append([wp(-13.5,0,-7.6),"small island outer approach"])
	route.append([wp(-13.5,0,-18.6),"small island rear bypass"])
	for x in [-8.53,-7.27]:
		route.append([wp(x,0,-18.6),"106-107 rear door alignment"])
		route.append([wp(x,0,-16.1),"small rear enter "+str(x)])
		route.append([wp(x,0,-18.6),"small rear exit "+str(x)])
	route.append([wp(-13.5,0,-18.6),"rear return"])
	route.append([wp(-13.5,0,-8),"cross aisle return"])
	route.append([wp(-18,0,-8),"public wing return"])
	route.append([wp(-18,0,10),"front public hall"])
	await fixture(wp(-18,.3,10),route)
	var checks:Array=[]
	for sample:Array in [[Vector3(-28.2,1.6,0),Vector3(-26.8,1.6,0),"shared dividing wall"],[Vector3(-35,1.6,0),Vector3(-33,1.6,0),"outer glass collider"],[Vector3(-35,1.6,4),Vector3(-32,1.6,1),"rounded glass corner"]]:
		var a:Vector3=sample[0];var c:Vector3=sample[1]
		var q:=PhysicsRayQueryParameters3D.create(wp(a.x,a.y,a.z),wp(c.x,c.y,c.z));q.exclude=[world.player.get_rid()]
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(q)
		checks.append({"case":sample[2],"valid":not hit.is_empty()})
		if hit.is_empty():failures.append(sample[2])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":1,"no_teleport_within_fixture":true,"scope":"Eight refitted shared-room entrances and exterior aisles only;full-plan metric registration pending"}
	FileAccess.open("res://tests/artifacts/library_study_pods_v101.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_STUDY_PODS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
