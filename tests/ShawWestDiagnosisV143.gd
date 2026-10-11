extends "res://tests/ShawWestPlanV143.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.player.set_physics_process(false);building=world.builder.buildings.shaw_west
	for x:float in [9,7,5,3.6,1,-2.9]:
		for y:float in [1,3,5,7,10]:
			var a:=wp(x,y,28.7);var c:=wp(x,-1,28.7)
			var h:=world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(a,c,1))
			if not h.is_empty():print("DIAG ",x," ",y," local=",building.to_local(h.position)," body=",h.collider.get_path()," normal=",h.normal)
	quit()
