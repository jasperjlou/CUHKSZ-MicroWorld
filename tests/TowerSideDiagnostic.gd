extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.player.set_physics_process(false)
	for y in [3.4,3.8,4.4,4.9]:
		var q:=PhysicsRayQueryParameters3D.create(Vector3(12.7,y,-794),Vector3(10.3,y,-794))
		var hit:=world.get_world_3d().direct_space_state.intersect_ray(q)
		if hit:print("SIDE_OBSTACLE ",y," ",hit.position," ",hit.collider.get_path())
		else:print("SIDE_CLEAR ",y)
	quit()
