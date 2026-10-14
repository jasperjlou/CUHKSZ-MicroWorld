extends "res://tests/LibraryLowerLevelCapture.gd"
var building:Node3D
func sp(p:Vector3)->Vector3:return building.to_global(p)
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(20)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	building=world.builder.buildings.shaw_east
	var route:Array=[]
	for p:Vector3 in [Vector3(-38.8,0,7.75),Vector3(-32,.45,7.75),Vector3(-25,.45,7.75),Vector3(-25,.45,10.7),Vector3(-21,.45,10.7),Vector3(-21,.45,23),Vector3(-20,.45,28),Vector3(-20,0,36),Vector3(-33,0,36),Vector3(-39,0,25),Vector3(-39,0,7.75),Vector3(-32,.45,7.75),Vector3(-39,0,7.75),Vector3(-39,0,0),Vector3(-32,.45,0),Vector3(-26,.45,0),Vector3(-32,.45,0),Vector3(-39,0,0)]:route.append([sp(p),"street portal/core/front/side "+str(p)])
	await fixture(sp(Vector3(-39,.3,0)),route)
	var checks:Array=[]
	for data:Array in [["core street wall",Vector3(-35,2,17),Vector3(-33,2,17),true],["portal headroom",Vector3(-31,4.3,8),Vector3(-31,5.5,8),false],["restored front upper floor",Vector3(-20,5.3,25),Vector3(-20,4.4,25),true],["portal entrance",Vector3(-35,2,8),Vector3(-31,2,8),false]]:
		var q=PhysicsRayQueryParameters3D.create(sp(data[1]),sp(data[2]));q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q)
		var valid:bool=(not hit.is_empty())==data[3]
		checks.append({"case":data[0],"valid":valid,"hit":str(hit.collider.get_path()) if not hit.is_empty() else ""})
		if not valid:failures.append(data[0])
	root.disable_3d=false;await frames(15)
	await capture("shaw-portal-v249-street",Vector3(57,4,-586),Vector3(77,5,-574))
	await capture("shaw-portal-v249-entry",sp(Vector3(-42,2.2,7.75)),sp(Vector3(-23,4,7.75)))
	await capture("shaw-portal-v249-core",Vector3(63,4.2,-584),Vector3(67,5,-572))
	await capture("shaw-portal-v249-front",Vector3(38,4,-571),Vector3(53,5,-554))
	FileAccess.open("res://tests/artifacts/shaw_street_portal_v249.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"checks":checks,"physical_legs":legs,"failures":failures,"scope":"18 local entry/side/front legs and4changed structure rays;fit dimensions,not full-campus/camera acceptance"},"\t"))
	print("SHAW_PORTAL_V249 ",JSON.stringify({"legs":legs.size(),"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
