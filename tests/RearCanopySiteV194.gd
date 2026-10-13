extends "res://tests/CourtyardRefinementCapture.gd"
const C194:=preload("res://world/visual_campus/LibraryRearCanopy.gd")
const B194:=preload("res://world/visual_campus/RearRoadBank.gd")
func gp194(x:float,z:float)->Vector3:
	return Vector3(x,world.builder.height(x,z),z)
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var route:Array=[]
	for p:Vector2 in [Vector2(137,-239.8),Vector2(134.5,-239.8),Vector2(130.4,-239.8),Vector2(130.4,-245.8),Vector2(128,-245.8),Vector2(128,-239.8),Vector2(134.5,-239.8),Vector2(137,-239.8),Vector2(137,-253)]:route.append([gp194(p.x,p.y),"waiting-pad loop "+str(p)])
	await fixture(gp194(137,-253)+Vector3.UP*.3,route)
	await fixture(gp194(135,-252)+Vector3.UP*.3,[[gp194(135,-232),"road inner edge through grade transition"],[gp194(135,-252),"inner edge return"]])
	var checks:Array=[]
	for p:Vector2 in [Vector2(130.4,-242),Vector2(128,-245),Vector2(132,-239)]:
		var foot:=gp194(p.x,p.y);var q:=PhysicsRayQueryParameters3D.create(foot+Vector3.UP*1.9,foot+Vector3.UP*3.8,1)
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(q)
		var valid:bool=not hit.is_empty() and absf(hit.position.y-C194.level()-3.29)<.12
		checks.append({"case":"continuous canopy ceiling "+str(p),"valid":valid})
		if not valid:failures.append("canopy roof probe "+str(p))
	root.disable_3d=false;await frames(15)
	await capture("rear-v194-canopy-road",gp194(138,-252)+Vector3.UP*1.8,Vector3(C194.X,C194.level()+1.5,-242))
	await capture("rear-v194-under-roof",Vector3(130.4,C194.level()+1.7,-246),Vector3(133.5,C194.level()+1.7,-239.8))
	var x:float=B194.toe(B194.STAIR_Z,world.builder.rear_route);var y:float=B194.road_height(B194.STAIR_Z)
	await capture("rear-v194-flowering-bank",Vector3(x-8,y+2.0,B194.STAIR_Z-5),Vector3(x+5,y+3.8,B194.STAIR_Z))
	FileAccess.open("res://tests/artifacts/rear_canopy_site_v194.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":2,"scope":"Canopy flat bench,road connection/inner edge and actual roof;not whole library-Shaw route or surveyed registration"},"\t"))
	quit(0 if failures.is_empty() else 1)
