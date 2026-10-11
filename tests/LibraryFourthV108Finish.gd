extends "res://tests/LibraryDiagonalV107Capture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-fourth-v108-final-front",wp(-32.8,14.5,25.5),wp(-14,14.3,25.5))
	await capture("library-fourth-v108-final-cambridge",wp(-29.5,14.5,-20),wp(-28,14.2,-24.7))
	await capture("library-fourth-v108-final-diagonal",cp(4,14.5,10.5),cp(-4,14.3,9.1))
	var route:Array=[]
	for p:Vector2 in [Vector2(1,27),Vector2(-2,25.5),Vector2(-12,25.5),Vector2(-24,25.5),Vector2(-33.2,25.5),Vector2(-33.2,3),Vector2(-33.2,1),Vector2(-30,1),Vector2(-30,-7.8),Vector2(-32,-7.8),Vector2(-32,-19.6),Vector2(-31,-22.4),Vector2(-29,-22.4),Vector2(-31,-22.4),Vector2(-31,-19.6),Vector2(-26.4,-19.6),Vector2(-26.4,-8),Vector2(-32,-8),Vector2(-32,1),Vector2(-20,1),Vector2(-19.5,4.5),Vector2(-20,1),Vector2(-33.2,1),Vector2(-33.2,25.5),Vector2(-12,25.5),Vector2(-2,25.5),Vector2(1,27)]:
		route.append([wp(p.x,12.8,p.y),"left bands and Cambridge "+str(p)])
	for p:Vector3 in [Vector3(-4,12.8,10.5),Vector3(5,12.8,10.5)]:route.append([cp(p.x,p.y,p.z),"front diagonal return "+str(p)])
	for p:Vector2 in [Vector2(13,17),Vector2(13,13.3),Vector2(10,13.3)]:route.append([wp(p.x,12.8,p.y),"core return "+str(p)])
	for p in [Vector3(6.5,12.8,3.4),Vector3(3,12.8,3.4),Vector3(3,12.8,-6.2),Vector3(-3,12.8,-6.2),Vector3(-3,10.8,2),Vector3(-5.7,10.8,2),Vector3(-5.7,8.8,-6.2),Vector3(3,8.8,-6.2)]:route.append([cp(p.x,p.y,p.z),"4F return and3F descent "+str(p)])
	await fixture(cp(-4,13.1,10.5),route)
	var checks:Array=[]
	for sample in [[Vector3(-24,13.7,25.5),Vector3(-12,13.7,25.5),false,"front aisle between shortened stacks and chairs"],[Vector3(-30,14,-22.8),Vector3(-30,14,-24.3),true,"single pod enclosure"],[Vector3(-21,13.3,28.25),Vector3(-21,13.3,28.32),false,"moved rear chair no longer in wall reveal"]]:
		var a:Vector3=sample[0];var b:Vector3=sample[1];var q=PhysicsRayQueryParameters3D.create(wp(a.x,a.y,a.z),wp(b.x,b.y,b.z));q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var ok:bool=(not hit.is_empty())==sample[2]
		checks.append({"case":sample[3],"valid":ok});if not ok:failures.append(sample[3])
	var report={"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Continuation from preceding retained right-wing route;two-fixture evidence,not one complete continuous tour"}
	FileAccess.open("res://tests/artifacts/library_fourth_v108_final.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_FOURTH_FINAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
