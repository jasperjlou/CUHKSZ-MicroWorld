extends "res://tests/LibraryEntryApproachV117.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15);world.player.set_physics_process(false)
	for p in [Vector3(42,2.4,-285),Vector3(42,2.4,-300)]:
		for node in world.find_children("*","MeshInstance3D",true,false):
			var local:Vector3=node.to_local(p);var bounds:AABB=node.get_aabb().grow(.01)
			if local.x<bounds.position.x or local.x>bounds.end.x or local.z<bounds.position.z or local.z>bounds.end.z:continue
			if bounds.position.y>local.y+.5 or bounds.end.y<local.y-.5:continue
			print("COVER_CANDIDATE ",p," ",node.get_path()," local ",local," bounds ",bounds)
	for pair in [[Vector3(62.1,3.6,-243.4),Vector3(67,3.6,-251.5)],[Vector3(65.36638,3.54,-269.4291),Vector3(80,5.6,-271.5)]]:
		var q=PhysicsRayQueryParameters3D.create(pair[0],pair[1]);q.exclude=[world.player.get_rid()];q.hit_back_faces=true
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q)
		print("BLOCKER ",hit.get("position")," ",hit.collider.get_path() if not hit.is_empty() else "none")
	quit()
