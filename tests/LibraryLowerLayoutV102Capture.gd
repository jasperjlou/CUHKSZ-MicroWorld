extends "res://tests/LibraryStudyPodsV101Capture.gd"

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-layout-v102-paired",wp(-20.4,1.8,8),wp(-19,1.8,-3))
	await capture("library-layout-v102-rear",wp(-20.4,1.8,-7),wp(-13,1.8,-9))
	await capture("library-layout-v102-110",wp(-8.8,1.8,-5.2),wp(-6.5,1.8,.3))
	await capture("library-layout-v102-screen",wp(-14,1.8,13),wp(-7,1.8,6.3))
	var route:Array=[[wp(-20.4,0,4.1),"front aisle between islands"]]
	for x in [-16.33,-15.07]:
		route.append([wp(x,0,3.6),"108-109 doorway alignment"])
		route.append([wp(x,0,.1),"small front room enter "+str(x)])
		route.append([wp(x,0,3.6),"small front room exit "+str(x)])
	route.append([wp(-20.4,0,3.6),"shared island gap approach"])
	route.append([wp(-20.4,0,-7),"shared island gap to rear aisle"])
	for x in [-16.33,-15.07]:
		route.append([wp(x,0,-7),"106-107 doorway alignment"])
		route.append([wp(x,0,-3.7),"small rear room enter "+str(x)])
		route.append([wp(x,0,-7),"small rear room exit "+str(x)])
	route.append([wp(-14.7,0,-7),"105 approach behind study islands"])
	route.append([wp(-14.7,0,-9.3),"105 enter"])
	route.append([wp(-14.7,0,-7),"105 exit"])
	route.append([wp(-9,0,-7),"rear aisle to110"])
	route.append([wp(-4,0,-4.1),"110 outer approach"])
	route.append([wp(-4,0,-.65),"110 doorway alignment"])
	route.append([wp(-6,0,-.65),"110 enter"])
	route.append([wp(-4,0,-.65),"110 exit"])
	route.append([wp(-4.2,0,3.7),"111 door approach beside retained stair"])
	route.append([wp(-6.2,0,5.6),"111 enter opposite display wall"])
	route.append([wp(-4.2,0,3.7),"111 exit"])
	route.append([wp(-4,0,10.7),"display side to front stair foot"])
	route.append([wp(-11,0,11),"display public frontage"])
	route.append([wp(-18,0,10),"arrival hall return"])
	route.append([wp(-20.4,0,4.1),"island gap return"])
	route.append([wp(-20.4,0,-7),"rear aisle return"])
	route.append([wp(-20.4,0,-14.5),"rear open learning area"])
	route.append([wp(-29,0,-14.5),"former105 location now open"])
	route.append([wp(-29,0,-8.3),"remote core cross aisle"])
	route.append([wp(-32.5,0,-8.3),"remote core retained access"])
	route.append([wp(-32.5,0,-7),"101-102 rear approach"])
	for x in [-28.13,-26.87]:
		route.append([wp(x,0,-7),"101-102 aligned"])
		route.append([wp(x,0,-4.6),"large rear room enter "+str(x)])
		route.append([wp(x,0,-7),"large rear room exit "+str(x)])
	route.append([wp(-20.4,0,-7),"large island flank approach"])
	route.append([wp(-20.4,0,3.6),"large island front return"])
	for x in [-28.13,-26.87]:
		route.append([wp(x,0,3.6),"103-104 aligned"])
		route.append([wp(x,0,.9),"large front room enter "+str(x)])
		route.append([wp(x,0,3.6),"large front room exit "+str(x)])
	route.append([wp(-20.4,0,3.6),"shared learning aisle final"])
	route.append([wp(-18,0,10),"arrival final"])
	await fixture(wp(-18,.3,10),route)
	var checks:Array=[]
	for sample:Array in [[Vector3(-18,1.6,-1.8),Vector3(-13,1.6,-1.8),true,"relocated central divider"],[Vector3(-24,1.6,-14),Vector3(-24,1.6,-18),false,"former105 volume cleared"],[Vector3(-7,1.6,-10),Vector3(-7,1.6,-17),false,"former106-109 volume cleared"],[Vector3(-9.8,1.6,9.2),Vector3(-7.9,1.6,7.4),true,"111 display backing"]]:
		var a:Vector3=sample[0];var c:Vector3=sample[1]
		var q:=PhysicsRayQueryParameters3D.create(wp(a.x,a.y,a.z),wp(c.x,c.y,c.z));q.exclude=[world.player.get_rid()]
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(q)
		var valid:bool=(not hit.is_empty())==sample[2]
		checks.append({"case":sample[3],"valid":valid,"collider":str(hit.collider.get_path()) if not hit.is_empty() else "none"})
		if not valid:failures.append(sample[3])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":1,"no_teleport_within_fixture":true,"scope":"Map-relative105-111 layout,display and affected front/rear public aisles;stair identity/whole footprint not registered"}
	FileAccess.open("res://tests/artifacts/library_lower_layout_v102.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_LOWER_LAYOUT ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
