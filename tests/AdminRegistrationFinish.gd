extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("admin-rear-registration-v41",Vector3(111,17,-154),Vector3(92,20,-188))
	await capture("admin-corner-door-v41",Vector3(102,16.3,-155),Vector3(93,17.8,-146))
	var guards: Array=[]
	for test: Array in [
		[Vector3(103,15.6,-171),Vector3(103,15.6,-168),"positive stair-well guard"],
		[Vector3(103,15.6,-189),Vector3(103,15.6,-192),"negative stair-well guard"],
		[Vector3(113,16.0,-172),Vector3(113,16.0,-168),"raised overlook guard"]]:
		var q:=PhysicsRayQueryParameters3D.create(test[0],test[1]);q.exclude=[world.player.get_rid()]
		var hit:=world.get_world_3d().direct_space_state.intersect_ray(q)
		var valid: bool=not hit.is_empty() and hit.collider.name=="AdministrationUpperStairGuards"
		guards.append({"guard":test[2],"valid":valid})
		if not valid:failures.append(test[2])
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"guard_checks":guards,"build_ms":world.built_ms,"scope":"Final opaque glazing reflections and added void-guard collision; 18 route legs unchanged from admin_registration_v41.json."}
	FileAccess.open("res://tests/artifacts/admin_registration_finish_v41.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ADMIN_REGISTRATION_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
