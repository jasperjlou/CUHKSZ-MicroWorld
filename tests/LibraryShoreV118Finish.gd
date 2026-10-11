extends "res://tests/LibraryEntryApproachV117.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-shore-v118-finish-overview",Vector3(-1,33,-226),Vector3(65,8,-290))
	await capture("library-shore-v118-finish-fins",Vector3(36,5.5,-310),Vector3(59,7,-316))
	await capture("library-shore-v118-finish-lawn",ap(27,45,12),ap(5,15,3.5))
	await capture("library-shore-v118-finish-soffit",ap(0,7,1.3),ap(0,2.5,2.8))
	var lower:Array=[]
	for p in [wp(-12,0,18),wp(-12,0,13),wp(-12,0,10),wp(-12,0,13),wp(-12,0,18),Vector3(60,2.24,-300)]:lower.append([p,"G threshold retained after pond extension "+str(p)])
	await fixture(Vector3(60,2.54,-300),lower)
	var lawn=preload("res://world/visual_campus/LibraryEntryLawn.gd")
	var route:Array=[]
	for z in [35.0,27.0,19.0,12.0,19.0,27.0,35.0]:
		var p:Vector3=Approach.point(lawn.outer(z)+1.0,z,.135);route.append([wp(p.x,p.y,p.z),"lawn outer walk "+str(z)])
	var start:Vector3=Approach.point(lawn.outer(37)+1.0,37,.435)
	await fixture(wp(start.x,start.y,start.z),route)
	var checks:Array=[]
	for v in [Vector3(52,2.4,-316),Vector3(60,2.4,-324.8),Vector3(27,2.4,-275),Vector3(49,2.4,-280),Vector3(45,2.4,-269)]:
		var q=PhysicsRayQueryParameters3D.create(v,v-Vector3.UP);q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var ok:bool=not hit.is_empty() and absf(hit.position.y-1.54)<.025
		checks.append({"case":"basin exact clipping "+str(v),"valid":ok,"hit":str(hit.get("position"))});if not ok:failures.append(str(v))
	var report={"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":2,"scope":"new pond extension,local G entrance and lawn outer path;initial16 south-perimeter/main approach legs retained;initial13 longerGroute superseded"}
	FileAccess.open("res://tests/artifacts/library_shore_v118_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_SHORE_V118_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
