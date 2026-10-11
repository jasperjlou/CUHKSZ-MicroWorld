extends "res://tests/LibraryDiagonalV107Capture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false)
	var route:Array=[]
	# The z=-8 shortcut aimed through the occupied chair row; use the clear cross aisle.
	for p:Vector2 in [Vector2(-26.4,-7.45),Vector2(-32,-7.45),Vector2(-32,1),Vector2(-20,1),Vector2(-19.5,4.5),Vector2(-20,1),Vector2(-33.2,1),Vector2(-33.2,25.5),Vector2(-12,25.5),Vector2(-2,25.5),Vector2(1,27)]:
		route.append([wp(p.x,12.8,p.y),"clear left cross aisle and return "+str(p)])
	for p:Vector3 in [Vector3(-4,12.8,10.5),Vector3(5,12.8,10.5)]:route.append([cp(p.x,p.y,p.z),"front diagonal return "+str(p)])
	for p:Vector2 in [Vector2(13,17),Vector2(13,13.3),Vector2(10,13.3)]:route.append([wp(p.x,12.8,p.y),"core return "+str(p)])
	for p in [Vector3(6.5,12.8,3.4),Vector3(3,12.8,3.4),Vector3(3,12.8,-6.2),Vector3(-3,12.8,-6.2),Vector3(-3,10.8,2),Vector3(-5.7,10.8,2),Vector3(-5.7,8.8,-6.2),Vector3(3,8.8,-6.2)]:route.append([cp(p.x,p.y,p.z),"4F return and3F descent "+str(p)])
	await fixture(wp(-26.4,13.1,-8),route)
	var report={"version":world.data.version,"physical_legs":legs,"failures":failures,"fixtures":1,"geometry_changed":false,"scope":"Continue from last left-wing valid point via actual cross aisle,returnto4F core anddescendto3F;no replay of passed rightwing"}
	FileAccess.open("res://tests/artifacts/library_fourth_v108_return.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_FOURTH_RETURN ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
