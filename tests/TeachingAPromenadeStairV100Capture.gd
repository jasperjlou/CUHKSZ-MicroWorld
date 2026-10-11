extends "res://tests/TeachingAArcadeV97Capture.gd"

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var n:Node3D=world.builder.buildings.teaching_a.get_node("TeachingACad")
	if DisplayServer.get_name()!="headless":
		await capture("ta-v100-stair-front",n.to_global(Vector3(12,2,107)),n.to_global(Vector3(14,4.5,93)))
		await capture("ta-v100-stair-below",n.to_global(Vector3(24,2,94)),n.to_global(Vector3(7,4,93)))
		await capture("ta-v100-stair-opening",n.to_global(Vector3(24,10.4,92)),n.to_global(Vector3(8,7,94)))
		await capture("ta-v100-lawn",n.to_global(Vector3(-24,2,114)),n.to_global(Vector3(26,14,92)))
	else:
		var route:Array=[]
		for a:Array in [
			[Vector3(21.5,0,92),"outside stair toe"],[Vector3(6.7,4.2,92),"lower flight and middle landing"],
			[Vector3(6.7,4.2,91.6),"middle platform door approach"],[Vector3(7.1,4.2,91.6),"door alignment"],
			[Vector3(7.1,4.2,89.5),"second-floor actual wall opening"],[Vector3(7.1,4.2,91.6),"second-floor return"],
			[Vector3(6.7,4.2,91.6),"landing turn clear of lower handrail"],[Vector3(6.7,4.2,94),"upper flight approach"],
			[Vector3(21.5,8.7,94),"upper flight through slab opening"],[Vector3(22.5,8.7,94),"upper landing clearance"],
			[Vector3(22.5,8.7,92),"inner promenade transfer"],[Vector3(-10,8.7,92),"continuous walk behind opening"],
			[Vector3(0,8.7,92),"low-wing approach"],[Vector3(0,8.7,88),"low-wing upper access"],
			[Vector3(0,8.7,92),"low-wing return"],[Vector3(24,8.7,92),"gallery toward lobby"],
			[Vector3(24,8.7,87),"upper lobby connection"],[Vector3(24,8.7,92),"upper lobby return"],
			[Vector3(22.5,8.7,92),"stair return approach"],[Vector3(22.5,8.7,94),"stair return turn"],
			[Vector3(6.7,4.2,94),"upper descent"],[Vector3(6.7,4.2,92),"middle landing return"],
			[Vector3(21.5,0,92),"lower descent to promenade"],[Vector3(28.5,0,92),"entry approach"],
			[Vector3(28.5,0,89.5),"existing ground entrance"],[Vector3(28.5,0,99),"return outside canopy"]]:route.append([n.to_global(a[0]),a[1]])
		await fixture(n.to_global(Vector3(24,.3,92)),route)
		for a:Array in [[Vector3(13,9.4,92),Vector3(13,9.4,94),"inner opening guard"],[Vector3(4.8,9.4,94),Vector3(6.8,9.4,94),"opening end guard"]]:
			var hit:=world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(n.to_global(a[0]),n.to_global(a[1]),1))
			if hit.is_empty():failures.append(a[2])
			print("V100_GUARD ",a[2]," ",not hit.is_empty())
	var report:Dictionary={"version":world.data.version,"physical_legs":legs,"failures":failures,"captures":captures,"headless":DisplayServer.get_name()=="headless","fixtures":1,"scope":"continuous ground to2F and3F front stair loop,new gallery opening,guard and existing entry;dated CAD with fitted widths/position"}
	FileAccess.open("res://tests/artifacts/teaching_promenade_stair_v100_%s.json" % ("physics" if DisplayServer.get_name()=="headless" else "views"),FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TEACHING_PROMENADE_STAIR_V100 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
