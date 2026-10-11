extends "res://tests/TeachingAArcadeV97Capture.gd"

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var n:Node3D=world.builder.buildings.teaching_a.get_node("TeachingACad")
	if DisplayServer.get_name()!="headless":
		await capture("ta-v99-lawn-front",n.to_global(Vector3(11,2.0,124)),n.to_global(Vector3(11,14.0,90)))
		await capture("ta-v99-promenade",n.to_global(Vector3(-27,2.0,113)),n.to_global(Vector3(27,15,92)))
		await capture("ta-v99-upper-gallery",n.to_global(Vector3(-8,10.3,94)),n.to_global(Vector3(30,10.5,94)))
		await capture("ta-v99-dark-cantilever",n.to_global(Vector3(50,16,120)),n.to_global(Vector3(23,25,82)))
	else:
		var route:Array=[]
		for a:Array in [
			[Vector3(24,8.7,93.5),"upper lobby to new gallery"],
			[Vector3(0,8.7,93.5),"continuous upper gallery toward low wing"],
			[Vector3(0,8.7,88),"low wing opening replaces slit wall"],
			[Vector3(0,8.7,93.5),"low wing back to gallery"],
			[Vector3(-12,8.7,93.5),"near gallery end guard"],
			[Vector3(33,8.7,93.5),"full gallery traverse"],
			[Vector3(24,8.7,93.5),"gallery return"],
			[Vector3(24,8.7,87),"upper lobby return"]]:route.append([n.to_global(a[0]),a[1]])
		await fixture(n.to_global(Vector3(24,9.0,87)),route)
		await fixture(n.to_global(Vector3(28.5,.3,99)),[
			[n.to_global(Vector3(28.5,0,93)),"lower canopy entrance"],
			[n.to_global(Vector3(28.5,0,89.5)),"existing entry retained"],
			[n.to_global(Vector3(28.5,0,99)),"entry return"]])
		for a:Array in [[Vector3(0,9.6,94.6),Vector3(0,9.6,97),"front glass guard"],[Vector3(-14,9.5,93.5),Vector3(-16,9.5,93.5),"near end guard"],[Vector3(36,9.5,93.5),Vector3(38,9.5,93.5),"far end guard"]]:
			var hit:=world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(n.to_global(a[0]),n.to_global(a[1]),1))
			if hit.is_empty():failures.append(a[2])
			print("V99_GUARD ",a[2]," ",not hit.is_empty())
	var report:Dictionary={"version":world.data.version,"physical_legs":legs,"failures":failures,"captures":captures,"headless":DisplayServer.get_name()=="headless","scope":"new upper gallery connections and guards; lower portal; historical roof height and observed envelope, site orientation still fitted"}
	FileAccess.open("res://tests/artifacts/teaching_front_v99_%s.json" % ("physics" if DisplayServer.get_name()=="headless" else "views"),FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TEACHING_FRONT_V99 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
