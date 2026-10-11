extends "res://tests/CourtyardRefinementCapture.gd"

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("admin-rear-registration-v41",Vector3(111,17,-154),Vector3(92,20,-188))
	await capture("admin-corner-door-v41",Vector3(102,16.3,-155),Vector3(93,17.8,-146))
	await capture("admin-undercroft-v41",Vector3(99,13,-186),Vector3(77,16,-179))
	await capture("admin-front-registration-v41",Vector3(3,13,-137),Vector3(74,16,-180))
	# A ray through the public rear bay catches the old low slab even if a route can walk around it.
	var q:=PhysicsRayQueryParameters3D.create(Vector3(90,12,-180),Vector3(90,25,-180))
	q.exclude=[world.player.get_rid()]
	var hit:=world.get_world_3d().direct_space_state.intersect_ray(q)
	var soffit_y: float=hit.position.y if not hit.is_empty() else -1.0
	if absf(soffit_y-18.10)>.15:failures.append("rear undercroft soffit still at wrong floor")
	await fixture(Vector3(112,14.94,-180),[
		[Vector3(112,14.64,-192),"main head to opposite low aisle"],
		[Vector3(98,14.64,-192),"low aisle around guarded stair opening"],
		[Vector3(96,14.64,-192),"transverse gallery outer approach"],
		[Vector3(96,14.64,-168),"transverse gallery above second landing"],
		[Vector3(96,14.64,-148),"corner gallery over flush wing roof"],
		[Vector3(90,14.64,-148),"relocated 4F glazed entrance"],
		[Vector3(96,14.64,-148),"corner lobby return"],
		[Vector3(96,14.64,-168),"gallery return to positive side aisle"],
		[Vector3(104,14.64,-168),"lookout stair approach along low aisle"],
		[Vector3(113,15.24,-168),"four steps onto raised overlook"],
		[Vector3(104,14.64,-168),"lookout descent along correct opening"],
		[Vector3(96,14.64,-168),"positive side aisle return"],
		[Vector3(96,14.64,-192),"transverse gallery return"],
		[Vector3(112,14.64,-192),"opposite aisle back to rear landing"],
		[Vector3(112,14.64,-180),"main stair head"],
		[Vector3(95,11.04,-180),"third flight descent"],
		[Vector3(75,6.64,-180),"second flight descent"],
		[Vector3(55,2.24,-180),"first flight descent to forecourt"]])

	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"retained_initial_checks":"First three ascent legs, opposite gallery pair and soffit ray in admin_registration_v41_initial.json remain valid; failed diagonal through stair void is not retained","no_teleport_within_each_fixture":true,"rear_soffit_y":soffit_y,"expected_rear_soffit_y":18.10,"build_ms":world.built_ms,"scope":"Rear 3-row office facade above 4F undercroft, relocated corner entrance, gallery connections and main stair access. Metric fitting and all B-zone fidelity remain incomplete."}
	FileAccess.open("res://tests/artifacts/admin_registration_v41.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ADMIN_REGISTRATION ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
