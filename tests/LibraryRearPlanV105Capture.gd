extends "res://tests/LibraryStudyPodsV101Capture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-rear-v105-left",wp(-22,1.8,-9),wp(-16,1.8,-16.5))
	await capture("library-rear-v105-recess",wp(1,1.8,-9),wp(8,1.8,-16))
	await capture("library-rear-v105-core",wp(-30,1.8,-13),wp(-32,1.8,-21))
	await capture("library-rear-v105-119",wp(13,1.8,-11),wp(20,1.8,-19))
	var route:Array=[]
	for p in [Vector3(-22,0,-12),Vector3(-18,0,-14.4),Vector3(-11,0,-14.4),Vector3(-3,0,-14),Vector3(2,0,-11),Vector3(4,0,-11),Vector3(8,0,-14),Vector3(12,0,-14),Vector3(12,0,-12),Vector3(12,0,-6),Vector3(14,0,-5),Vector3(12,0,-6),Vector3(12,0,-14),Vector3(8,0,-14),Vector3(4,0,-11),Vector3(2,0,-11),Vector3(-3,0,-14),Vector3(-11,0,-14.4),Vector3(-22,0,-14.4),Vector3(-30,0,-14.4),Vector3(-32,0,-18),Vector3(-32.5,0,-21),Vector3(-30,0,-21),Vector3(-30,.48,-24),Vector3(-30,.48,-27),Vector3(-30,0,-31.2),Vector3(-30,.48,-27),Vector3(-30,.48,-24),Vector3(-30,0,-21),Vector3(-30,0,-14.4),Vector3(-22,0,-12)]:route.append([wp(p.x,p.y,p.z),"registered rear "+str(p)])
	await fixture(wp(-22,.3,-8),route)
	var checks:Array=[]
	for s in [[Vector3(-8,1.5,-15),Vector3(-8,1.5,-18),true,"new long rear wall"],[Vector3(4,1.5,-12),Vector3(4,1.5,-15),true,"ground rear recess"],[Vector3(8,.5,-14),Vector3(8,-.2,-14),true,"lower rear floor exists"],[Vector3(-30,1.5,-19),Vector3(-26,1.5,-19),true,"vestibule return enclosure"]]:
		var a:Vector3=s[0];var b:Vector3=s[1];var q=PhysicsRayQueryParameters3D.create(wp(a.x,a.y,a.z),wp(b.x,b.y,b.z));q.exclude=[world.player.get_rid()]
		var h=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=(not h.is_empty())==s[2]
		checks.append({"case":s[3],"valid":valid})
		if not valid:failures.append(s[3])
	var report={"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Ground rear wall,floor,recess,remote core andexistingrearporch;upperfloor/sitefidelitynotclaimed"}
	FileAccess.open("res://tests/artifacts/library_rear_plan_v105.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_REAR_PLAN ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
