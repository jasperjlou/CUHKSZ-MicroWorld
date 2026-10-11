extends "res://tests/CourtyardRefinementCapture.gd"

func walk(target: Vector3,label: String) -> bool:
	var player:CharacterBody3D=world.player;var count:=0;var lowest:=player.position.y;var checkpoint:=player.position
	while Vector2(target.x-player.position.x,target.z-player.position.z).length()>.65 and count<1800:
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
	var route:Array=[]
	for a:Array in [
		[Vector3(7.5,-5.15,38.4),"lower stair toe clear"],[Vector3(1,-5.15,38.4),"court beyond stair guards"],[Vector3(1,-5.15,40),"lower court walk"],
		[Vector3(1,-5.15,38.4),"court return via toe"],[Vector3(7.5,-5.15,38.4),"lower court return"],[Vector3(7.5,-2.575,50),"lower flight ascent"],
		[Vector3(6,-2.575,50),"mid landing return"],[Vector3(-1,0,50),"upper flight ascent"],
		[Vector3(-3.7,0,50),"west corridor return"],[Vector3(-3.7,0,73.5),"front cross passage"],
		[Vector3(26.8,0,73.5),"lobby return"],[Vector3(28,0,78),"lobby stair toe"],
		[Vector3(28,2.1,87),"lobby first flight"],[Vector3(32,2.1,87),"lobby mid landing"],
		[Vector3(32,4.2,77.5),"second floor arrival"],[Vector3(20,4.2,77.5),"second floor lobby ring"],
		[Vector3(32,4.2,77.5),"upper landing return"],[Vector3(32,2.1,87),"second flight descent"],
		[Vector3(28,2.1,87),"mid landing transfer"],[Vector3(28,0,78),"lobby ground return"]]:route.append([n.to_global(a[0]),a[1]])
	await fixture(n.to_global(Vector3(7.5,-4.85,39)),route)
	var report:Dictionary={"version":world.data.version,"failures":failures,"captures":captures,"physical_legs":legs,"scope":"TA CAD ground courts, lower court and public lobby stairs;historical plans and fitted global registration"}
	FileAccess.open("res://tests/artifacts/teaching_a_cad_complete_v96.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TEACHING_A_CAD_V96 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
