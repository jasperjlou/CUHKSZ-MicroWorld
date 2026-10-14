extends "res://tests/LibraryLowerLevelCapture.gd"
var building:Node3D
func sp(x:float,y:float,z:float)->Vector3:return building.to_global(Vector3(x,y,z))
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(20)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	building=world.builder.buildings.shaw_east
	var route:Array=[]
	for p:Vector3 in [Vector3(-35.5,.45,0),Vector3(-32,.45,0),Vector3(-26,.45,0),Vector3(-26,.45,-6),Vector3(-26,.45,0),Vector3(-32,.45,0),Vector3(-35.5,.45,0),Vector3(-39,0,0),Vector3(-39,0,18),Vector3(-39,0,25),Vector3(-33,0,36),Vector3(-20,0,36),Vector3(-20,.45,28),Vector3(-20,.45,20),Vector3(-20,.45,28),Vector3(-20,0,36)]:route.append([building.to_global(p),"side and front approach "+str(p)])
	await fixture(sp(-39,.3,0),route)
	var checks:Array=[]
	for p:Vector3 in [Vector3(-34,.08,0),Vector3(34,.08,0),Vector3(0,.08,-29.3),Vector3(0,.08,29.3)]:
		var normal:Vector3=Vector3(signf(p.x),0,signf(p.z))
		var q=PhysicsRayQueryParameters3D.create(building.to_global(p+normal*.5),building.to_global(p-normal*.5));q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q)
		var valid:bool=not hit.is_empty() and "ShawGroundPlinthV247" in str(hit.collider.get_path())
		checks.append({"case":"solid plinth below existing slab "+str(p),"valid":valid})
		if not valid:failures.append("plinth "+str(p))
	root.disable_3d=false;await frames(15)
	await capture("shaw-ground-v247-side",sp(-43,2.2,2),sp(-28,2,-2))
	await capture("shaw-ground-v247-wall",Vector3(76,3.7,-579),Vector3(80,2.62,-574))
	await capture("shaw-ground-v247-front",Vector3(38,4,-571),Vector3(45,3.1,-546))
	await capture("shaw-ground-v247-pavers",Vector3(42,4.1,-563),Vector3(42,2.4,-558))
	await capture("shaw-ground-v247-junction",Vector3(88,14,-588),Vector3(85,2.5,-575))
	FileAccess.open("res://tests/artifacts/shaw_ground_edges_v247.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"checks":checks,"physical_legs":legs,"failures":failures,"scope":"16leg side-room to front-entry loop plus4plinth probes;camera views are independent fixtures;not full-campus or measured geometry acceptance"},"\t"))
	print("SHAW_GROUND_V247 ",JSON.stringify({"legs":legs.size(),"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
