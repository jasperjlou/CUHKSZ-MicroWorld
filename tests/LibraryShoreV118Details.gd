extends "res://tests/LibraryEntryApproachV117.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-shore-v118-details-overview",Vector3(-1,33,-226),Vector3(65,8,-290))
	await capture("library-shore-v118-details-lawn",ap(27,45,12),ap(5,15,3.5))
	await capture("library-shore-v118-details-soffit",ap(0,7,1.3),ap(0,2.5,2.8))
	var checks:Array=[]
	for pair in [[ap(0,5.2,4.3),ap(0,5.2,3.65),false,"slab top stays below exterior stair clearance"],[ap(0,7,1.4),ap(0,7,2.65),true,"soffit underside remains closed"]]:
		var q=PhysicsRayQueryParameters3D.create(pair[0],pair[1]);q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var ok:bool=not hit.is_empty() if pair[2] else hit.is_empty()
		checks.append({"case":pair[3],"valid":ok});if not ok:failures.append(pair[3])
	var report={"version":world.data.version,"captures":captures,"checks":checks,"failures":failures,"scope":"non-walkway lawn triangulation,visual border clipping,closed116slab;no repeated full route"}
	FileAccess.open("res://tests/artifacts/library_shore_v118_details.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_SHORE_DETAILS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
