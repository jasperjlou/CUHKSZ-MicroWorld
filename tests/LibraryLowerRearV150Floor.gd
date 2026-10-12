extends "res://tests/LibraryLowerRearV150.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for v in [[4.3,.13716667],[4.5,.106],[4.7,.106]]:
		var q:=PhysicsRayQueryParameters3D.create(dp(0,.6,v[0]),dp(0,-.1,v[0]));q.exclude=[world.player.get_rid()]
		var hit:=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=not hit.is_empty() and absf(hit.position.y-2.24-v[1])<.025
		checks.append({"case":"ramp/vestibule joint "+str(v[0]),"valid":valid})
		if not valid:failures.append("floor joint "+str(v[0]))
	await capture("library-lower-rear-v150-vestibule-finish",dp(0,1.75,10),dp(0,1.75,-2))
	FileAccess.open("res://tests/artifacts/library_lower_rear_v150_floor.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"checks":checks,"captures":captures,"failures":failures,"scope":"Raised inner finish0.106m andshallower ramp end only;other routes retained"},"\t"))
	print("LIBRARY_REAR_FLOOR ",JSON.stringify({"checks":checks.size(),"failures":failures}))
	quit(0 if failures.is_empty() else 1)
