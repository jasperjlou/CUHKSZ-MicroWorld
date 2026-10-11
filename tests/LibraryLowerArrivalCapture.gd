extends "res://tests/LibraryLowerLevelCapture.gd"
## One batch after the lower arrival, partitions and public programme are rebuilt.
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-exhibition-v72",wp(-14,1.75,21),wp(-22,1.7,16))
	await capture("library-arrival-v72",wp(-18,1.8,27),wp(-12,1.6,19))
	await capture("library-open-lower-v72",wp(-10,1.75,7),wp(8,1.85,-7))
	await capture("library-stair-pocket-v72",wp(-5.5,1.7,0),wp(1.5,2,-1))
	await capture("library-lower-screen-v72",wp(12,1.8,6),wp(7,2,-2.8))
	await fixture(wp(-18,.3,31),[
		[wp(-18,0,27),"lower public entrance"],[wp(-22.2,0,26.2),"security desk outer aisle"],
		[wp(-22.2,0,23),"past security desk end"],[wp(-18,0,21.5),"exhibition open approach"],
		[wp(-17.5,0,15),"exhibition interior"],[wp(-15,0,10),"exhibition to learning hall"],
		[wp(-10,0,6),"former generic lobby approach"],[wp(-10,0,-5),"removed glass partition crossing"],
		[wp(0,0,-.7),"stair underside high pocket"],[wp(0,0,-8),"understair return to central aisle"],
		[wp(18,0,-8),"central to right study wing"],[wp(18,0,10),"right wing screen aisle"],
		[wp(11,0,13.2),"phone rest outer passage"],[wp(0,0,12),"normal stair foot"],
		[wp(0,4.4,-4),"public stair ascent"],[wp(0,0,12),"public stair descent"],
		[wp(-8,0,12),"left arrival return"],[wp(-8,0,17),"student terminal frontage"],
		[wp(-9,0,21.8),"ITSO side approach"],[wp(-11,0,25.7),"ITSO public frontage"],
		[wp(-14,0,27),"curved entrance corridor"],[wp(-18,0,27),"lower entrance return"],
		[wp(-18,0,31),"outside lower entrance"]])
	var checks:Array=[]
	for sample:Array in [[Vector3(-10,1.6,1),Vector3(-10,1.6,-5),false,"former central glass line now open"],[Vector3(14,1.6,-6),Vector3(16,1.6,-6),false,"former side glass boundary now open"],[Vector3(7,1.6,0),Vector3(7,1.6,-3),true,"display backing solid"],[Vector3(0,1.6,-.7),Vector3(0,4,-.7),true,"stair underside overhead"],[Vector3(-18,1.6,16),Vector3(-24,1.6,16),true,"exhibition wall backing"]]:
		var a:Vector3=sample[0];var c:Vector3=sample[1]
		var q:=PhysicsRayQueryParameters3D.create(wp(a.x,a.y,a.z),wp(c.x,c.y,c.z));q.exclude=[world.player.get_rid()]
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=(not hit.is_empty())==sample[2]
		checks.append({"case":sample[3],"valid":valid,"collider":str(hit.collider.get_path()) if not hit.is_empty() else "none"})
		if not valid:failures.append(sample[3])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"scope":"1F/G beneath main entry: arrival exhibition,public service order,open circulation and retained stair;fitted not surveyed","no_teleport_within_fixture":true}
	FileAccess.open("res://tests/artifacts/library_lower_arrival_v72.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_LOWER_ARRIVAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
