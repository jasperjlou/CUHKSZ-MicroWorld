extends "res://tests/LibraryEntryApproachV117.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	root.size=Vector2i(1440,900)
	world.player.set_physics_process(false);world.overview.current=true
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=ap(0,7,1.3);world.overview.look_at(ap(0,2.5,2.8));await frames(3)
	for pixel in [Vector2(1140,519),Vector2(1110,519),Vector2(1160,519),Vector2(1140,530),Vector2(1140,506)]:
		var a:Vector3=world.overview.project_ray_origin(pixel);var dir:Vector3=world.overview.project_ray_normal(pixel)
		var q=PhysicsRayQueryParameters3D.create(a,a+dir*50);q.exclude=[world.player.get_rid()];q.hit_back_faces=true
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q)
		print("SOFFIT_RAY ",pixel," start ",a," direction ",dir," hit ",hit.get("position")," collider ",hit.collider.get_path() if not hit.is_empty() else "none")
	quit()
