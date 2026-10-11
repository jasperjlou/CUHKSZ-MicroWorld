extends "res://tests/LibraryLowerFrontV115.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-lower-front-v115-shell-final",wp(-22,16,98),wp(-15,13,23))
	await capture("library-lower-front-v115-second-final",wp(-19,6.2,9),wp(-7,6.1,15))
	var route:Array=[]
	for p in [Vector3(-23,4.4,4),Vector3(-21,4.4,4),Vector3(-17,4.4,4),Vector3(-10,4.4,4),Vector3(0,4.4,7),Vector3(-10,4.4,4),Vector3(-17,4.4,4),Vector3(-21,4.4,4),Vector3(-23,4.4,4)]:route.append([wp(p.x,p.y,p.z),"2F revised left wing "+str(p)])
	await fixture(wp(-23,4.7,7),route)
	var checks:Array=[]
	for p in [Vector3(-25,4.4,26),Vector3(-18,4.4,24)]:
		var q=PhysicsRayQueryParameters3D.create(wp(p.x,p.y+.2,p.z),wp(p.x,p.y-.15,p.z));q.exclude=[world.player.get_rid()];var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=hit.is_empty()
		checks.append({"case":"removed unregistered2Fprojection "+str(p),"valid":valid});if not valid:failures.append("old projection "+str(p))
	var report={"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":1,"scope":"final2Fleft clipping only;priorG/3Fchecks unaffected,right2F/mainstair/pool remain partial"}
	FileAccess.open("res://tests/artifacts/library_lower_front_v115_second.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_LOWER_SECOND ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
