extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
	var world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world)
	for i in 12:await physics_frame
	for x in [59.45,60.0,60.55]:
		for y in [2.3,2.65,3.6,4.7,5.05]:
			var q=PhysicsRayQueryParameters3D.create(Vector3(x,y,-334),Vector3(x,y,-330));q.exclude=[world.player.get_rid()]
			var hit=world.get_world_3d().direct_space_state.intersect_ray(q)
			if not hit.is_empty():print("V120_BLOCK ",hit.position," ",hit.collider.get_path()," shape=",hit.shape)
	quit()
