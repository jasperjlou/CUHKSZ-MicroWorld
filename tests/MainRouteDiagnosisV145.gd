extends "res://tests/ZhangDatumV137.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15);world.player.set_physics_process(false)
	for x:float in [-14,-13,-12.5,-12,-11,-10]:
		for y:float in [2.5,3,3.8]:
			var hit:=world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(x,y,-689),Vector3(x,y,-699),1))
			if not hit.is_empty():print("MAIN_BLOCK ",hit.position," body=",hit.collider.get_path()," normal=",hit.normal)
	quit()
