extends "res://tests/TeachingACadCompleteV96Capture.gd"

# Tight waypoints are needed to turn beyond the end of a stair handrail.
func walk(target: Vector3,label: String) -> bool:
	var player:CharacterBody3D=world.player;var count:=0;var lowest:=player.position.y;var checkpoint:=player.position
	while Vector2(target.x-player.position.x,target.z-player.position.z).length()>.22 and count<1800:
		player.navigation_direction=Vector2(target.x-player.position.x,target.z-player.position.z).normalized()
		await physics_frame;count+=1;lowest=minf(lowest,player.position.y)
		if count%120==0:
			if player.position.distance_to(checkpoint)<.12:break
			checkpoint=player.position
	player.navigation_direction=Vector2.ZERO;await frames(10)
	var distance:=Vector2(target.x-player.position.x,target.z-player.position.z).length()
	# CAD lower court is 2.24-5.15=-2.91 world Y; the generic -2.15 guard is inapplicable.
	var valid:=count<1800 and distance<1.1 and lowest> -3.4 and absf(player.position.y-target.y)<.5
	if not valid:
		failures.append(label)
		var hit:=world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(player.position+Vector3.UP*.9,target+Vector3.UP*.9,1))
		if hit:print("TA_COLLIDER ",hit.collider.get_path())
	legs.append({"goal":label,"valid":valid,"frames":count,"distance":distance,"lowest_y":lowest,"end":[player.position.x,player.position.y,player.position.z]})
	print("TA_CAD_LEG ",label," ",valid," ",player.position);return valid

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var n:Node3D=world.builder.buildings.teaching_a.get_node("TeachingACad")
	if DisplayServer.get_name()!="headless":
		await capture("ta-v97-stairs",n.to_global(Vector3(15.5,2,48.5)),n.to_global(Vector3(27,4.1,40.5)))
		await capture("ta-v97-gallery",n.to_global(Vector3(10,2,45)),n.to_global(Vector3(12,8,34)))
		await capture("ta-v97-entry",n.to_global(Vector3(33,2,98)),n.to_global(Vector3(24,4,91)))
		await capture("ta-v97-arcade",n.to_global(Vector3(17,2,53)),n.to_global(Vector3(34,4,63)))
		await capture("ta-v97-shade",n.to_global(Vector3(5,2,94)),n.to_global(Vector3(30,4,94)))
		FileAccess.open("res://tests/artifacts/teaching_a_arcade_views_v97.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	var route:Array=[]
	for a:Array in [
		[Vector3(20,0,46.5),"arcade stair approach"],[Vector3(20,0,43.3),"stair toe"],
		[Vector3(31.2,2.1,43.3),"first mid landing"],[Vector3(31.2,2.1,39.1),"first turn"],
		[Vector3(21.3,4.2,39.1),"second floor arrival"],[Vector3(22,4.2,35.8),"open gallery entry"],
		[Vector3(5,4.2,35.8),"open gallery walk"],[Vector3(22,4.2,35.8),"gallery return"],
		[Vector3(21.3,4.2,39.1),"upper stair transfer"],[Vector3(21.3,4.2,43.3),"upper flight toe"],
		[Vector3(31.2,6.45,43.3),"upper mid landing"],[Vector3(31.2,6.45,39.1),"upper turn"],
		[Vector3(21.3,8.7,39.1),"third floor arrival"],[Vector3(22,8.7,35.8),"third floor door"],
		[Vector3(21.3,8.7,39.1),"third floor return"],[Vector3(31.2,6.45,39.1),"upper second descent"],
		[Vector3(31.2,6.45,43.3),"upper mid return"],[Vector3(21.3,4.2,43.3),"second floor descent"],
		[Vector3(21.3,4.2,39.1),"second floor transfer"],[Vector3(31.2,2.1,39.1),"lower second descent"],
		[Vector3(31.2,2.1,43.3),"lower mid return"],[Vector3(20,0,43.3),"ground return"],
		[Vector3(20,0,54),"arcade return"]]:route.append([n.to_global(a[0]),a[1]])
	await fixture(n.to_global(Vector3(20,.3,54)),route)
	await fixture(n.to_global(Vector3(28.5,.3,99)),[[n.to_global(Vector3(28.5,0,93)),"canopy approach"],[n.to_global(Vector3(28.5,0,89.5)),"black frame portal"],[n.to_global(Vector3(28.5,0,99)),"entry return"]])
	var report:Dictionary={"version":world.data.version,"physical_legs":legs,"failures":failures,"fixtures":2,"no_teleport_within_fixture":true,"headless":true}
	FileAccess.open("res://tests/artifacts/teaching_a_arcade_v97.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TA_ARCADE_V97 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
