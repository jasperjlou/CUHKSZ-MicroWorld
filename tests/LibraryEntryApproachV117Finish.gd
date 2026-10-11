extends "res://tests/LibraryEntryApproachV117.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-entry-approach-v117-finish-front",ap(-12,47,12),ap(0,3,5))
	await capture("library-entry-approach-v117-finish-steps",ap(-2,13,4),ap(0,0,6.3))
	await capture("library-entry-approach-v117-finish-soffit",ap(0,7,1.3),ap(0,2.5,2.8))
	var route:Array=[]
	for p in [Vector3(0,0,8),Vector3(6,0,10),Vector3(8,0,12),Vector3(6,0,10),Vector3(0,0,8),Vector3(-2,0,8),Vector3(-3,0,9),Vector3(-6,0,10),Vector3(-9,0,11),Vector3(-12,0,10),Vector3(-13,0,14)]:route.append([wp(p.x,p.y,p.z),"G around111/display/terminal "+str(p)])
	var e:Vector3=Lower.entrance();route.append([wp(e.x,0,e.z),"registered G threshold return"])
	route.append([wp(-12,0,21),"G forecourt exit"])
	await fixture(wp(-12,.3,4),route)
	var checks:Array=[]
	for sample in [[ap(0,7,1.4),ap(0,7,2.65),"closed116 inclined soffit retained"],[ap(-6.6,6,3.4),ap(-7.0,6,3.4),"soffit side upstand closed"]]:
		var q=PhysicsRayQueryParameters3D.create(sample[0],sample[1]);q.exclude=[world.player.get_rid()];var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=not hit.is_empty()
		checks.append({"case":sample[2],"valid":valid});if not valid:failures.append(sample[2])
	var report={"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"G aisle/return using actual gaps,exact116 roof side closure;main route24 legs from accepted_run unchanged"}
	FileAccess.open("res://tests/artifacts/library_entry_approach_v117_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_ENTRY_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
