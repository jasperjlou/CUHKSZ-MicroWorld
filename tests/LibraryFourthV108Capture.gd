extends "res://tests/LibraryDiagonalV107Capture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-fourth-v108-stacks",wp(-33,14.55,1.7),wp(-24,14.25,-5))
	await capture("library-fourth-v108-window",wp(30,14.5,6),wp(34,14.2,-9))
	await capture("library-fourth-v108-cambridge",wp(-29.5,14.5,-20),wp(-28,14.2,-24.7))
	await capture("library-fourth-v108-front",wp(-32.8,14.5,26.3),wp(-14,14.3,25))
	var route:Array=[]
	for p in [Vector3(3,12.8,-6.2),Vector3(3,12.8,3.4),Vector3(6.5,12.8,3.4)]:route.append([cp(p.x,p.y,p.z),"4F core public approach "+str(p)])
	for p:Vector2 in [Vector2(10,13.3),Vector2(13,13.3),Vector2(16,10),Vector2(17,5),Vector2(17,.8),Vector2(25,7),Vector2(29,5),Vector2(32,2),Vector2(36,1),Vector2(34,1),Vector2(29,5),Vector2(25,7),Vector2(17,5),Vector2(17,.8),Vector2(17,-7),Vector2(20,-10),Vector2(25,-15),Vector2(29,-19),Vector2(30,-20),Vector2(29,-19),Vector2(25,-15),Vector2(20,-10),Vector2(17,-7),Vector2(17,.8),Vector2(17,5),Vector2(16,10),Vector2(13,13.3),Vector2(13,17)]:
		route.append([wp(p.x,12.8,p.y),"P-Z and window circulation "+str(p)])
	for p:Vector3 in [Vector3(5,12.8,10.5),Vector3(-4,12.8,10.5),Vector3(-7,12.8,10.5)]:route.append([cp(p.x,p.y,p.z),"A-D outside core "+str(p)])
	for p:Vector2 in [Vector2(1,28),Vector2(-1,26.2),Vector2(-12,26.2),Vector2(-24,26.2),Vector2(-33.2,26.2),Vector2(-33.2,3),Vector2(-33.2,1),Vector2(-30,1),Vector2(-30,-7.8),Vector2(-32,-7.8),Vector2(-32,-19.6),Vector2(-31,-22.4),Vector2(-29,-22.4),Vector2(-31,-22.4),Vector2(-31,-19.6),Vector2(-26.4,-19.6),Vector2(-26.4,-8),Vector2(-32,-8),Vector2(-32,1),Vector2(-20,1),Vector2(-19.5,4.5),Vector2(-20,1),Vector2(-33.2,1),Vector2(-33.2,26.2),Vector2(-12,26.2),Vector2(-1,26.2),Vector2(1,28)]:
		route.append([wp(p.x,12.8,p.y),"D-H H-P and Cambridge circulation "+str(p)])
	for p:Vector3 in [Vector3(-7,12.8,10.5),Vector3(5,12.8,10.5)]:route.append([cp(p.x,p.y,p.z),"front diagonal return "+str(p)])
	for p:Vector2 in [Vector2(13,17),Vector2(13,13.3),Vector2(10,13.3)]:route.append([wp(p.x,12.8,p.y),"core return "+str(p)])
	for p in [Vector3(6.5,12.8,3.4),Vector3(3,12.8,3.4),Vector3(3,12.8,-6.2),Vector3(-3,12.8,-6.2),Vector3(-3,10.8,2),Vector3(-5.7,10.8,2),Vector3(-5.7,8.8,-6.2),Vector3(3,8.8,-6.2)]:route.append([cp(p.x,p.y,p.z),"4F return and3F descent "+str(p)])
	await fixture(cp(-3,13.1,-6.2),route)
	var checks:Array=[]
	for sample in [[Vector3(-32,14,-3.8),Vector3(-30.5,14,-3.8),true,"stack body"],[Vector3(-30,14,-7.5),Vector3(-30,14,-.2),false,"between-stack aisle"],[Vector3(-30,14,-22.8),Vector3(-30,14,-24.3),true,"single pod glass"],[Vector3(-27,13.5,-21.4),Vector3(-27,13.8,-21.4),true,"table top collision"]]:
		var a:Vector3=sample[0];var b:Vector3=sample[1];var q=PhysicsRayQueryParameters3D.create(wp(a.x,a.y,a.z),wp(b.x,b.y,b.z));q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var ok:bool=(not hit.is_empty())==sample[2]
		checks.append({"case":sample[3],"valid":ok});if not ok:failures.append(sample[3])
	var report={"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Four reading bands,20 fitted tables,80 chairs,1 single cell;whole4F outline and public stair void registration not established"}
	FileAccess.open("res://tests/artifacts/library_fourth_v108.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_FOURTH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
