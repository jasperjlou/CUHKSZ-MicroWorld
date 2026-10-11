extends "res://tests/CourtyardRefinementCapture.gd"

func walk(target: Vector3,label: String) -> bool:
	var player:CharacterBody3D=world.player;var count:=0;var lowest:=player.position.y
	while Vector2(target.x-player.position.x,target.z-player.position.z).length()>.65 and count<1800:
		player.navigation_direction=Vector2(target.x-player.position.x,target.z-player.position.z).normalized()
		await physics_frame;count+=1;lowest=minf(lowest,player.position.y)
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
	await capture("ta-v96-plan",n.to_global(Vector3(-35,70,125)),n.to_global(Vector3(10,5,55)))
	await capture("ta-v96-court",n.to_global(Vector3(25,2,68)),n.to_global(Vector3(2,4,48)))
	await capture("ta-v96-lower",n.to_global(Vector3(12,-3.3,39)),n.to_global(Vector3(3,-1.5,49)))
	await capture("ta-v96-mall",n.to_global(Vector3(31,4,110)),n.to_global(Vector3(18,9,82)))
	var route:Array=[]
	for a:Array in [
		[Vector3(28.5,0,93),"front lobby threshold"],[Vector3(28.5,0,90.4),"front lobby portal"],
		[Vector3(24,0,90.4),"around stair landing"],[Vector3(24,0,73.5),"lobby cross corridor"],
		[Vector3(20,0,73.5),"open arcade head"],[Vector3(20,0,54),"tall arcade ground"],
		[Vector3(6,-.15,60),"inner court"],[Vector3(-3.7,0,60),"court west corridor"],
		[Vector3(-3.7,0,50),"sunken stair entrance"],[Vector3(-1,0,50),"sunken stair top"],
		[Vector3(6,-2.575,50),"transverse stair descent"],[Vector3(7.5,-2.575,50),"mid landing turn"],
		[Vector3(7.5,-5.15,39),"lower court descent"],[Vector3(1,-5.15,40),"lower court walk"],
		[Vector3(7.5,-5.15,39),"lower court return"],[Vector3(7.5,-2.575,50),"lower flight ascent"],
		[Vector3(6,-2.575,50),"mid landing return"],[Vector3(-1,0,50),"upper flight ascent"],
		[Vector3(-3.7,0,50),"west corridor return"],[Vector3(-3.7,0,73.5),"front cross passage"],
		[Vector3(24,0,73.5),"lobby return"],[Vector3(28,0,78),"lobby stair toe"],
		[Vector3(28,2.1,87),"lobby first flight"],[Vector3(32,2.1,87),"lobby mid landing"],
		[Vector3(32,4.2,77.5),"second floor arrival"],[Vector3(20,4.2,77.5),"second floor lobby ring"],
		[Vector3(32,4.2,77.5),"upper landing return"],[Vector3(32,2.1,87),"second flight descent"],
		[Vector3(28,2.1,87),"mid landing transfer"],[Vector3(28,0,78),"lobby ground return"]]:route.append([n.to_global(a[0]),a[1]])
	await fixture(n.to_global(Vector3(28.5,.3,97)),route)
	var report:Dictionary={"version":world.data.version,"failures":failures,"captures":captures,"physical_legs":legs,"scope":"TA CAD ground courts, lower court and public lobby stairs;historical plans and fitted global registration"}
	FileAccess.open("res://tests/artifacts/teaching_a_cad_v96.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TEACHING_A_CAD_V96 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
