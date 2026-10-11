extends "res://tests/LibraryEntryApproachV117.gd"
const Pool=preload("res://world/visual_campus/LibraryPoolFrontage.gd")
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-shore-v118-overview",Vector3(-1,33,-226),Vector3(65,8,-290))
	await capture("library-shore-v118-fins",Vector3(36,5.5,-310),Vector3(59,7,-316))
	await capture("library-shore-v118-lawn",ap(27,45,12),ap(5,15,3.5))
	await capture("library-shore-v118-soffit",ap(0,7,1.3),ap(0,2.5,2.8))
	var route:Array=[]
	for v in [Vector3(14,2.24,-283),Vector3(14,2.24,-267),Vector3(14,2.24,-251),Vector3(29,2.24,-251),Vector3(39,2.24,-249)]:route.append([v,"pool shore south perimeter "+str(v)])
	for z in [38.0,28.0,18.0,9.2,1.2,-2.0,1.2,9.2,18.0,28.0,38.0]:route.append([ap(0,z),"approach retained "+str(z)])
	await fixture(Vector3(14,2.54,-295),route)
	var lower:Array=[]
	for p in [Vector3(43,2.24,-274),Vector3(46,2.24,-290),Vector3(54,2.24,-301),Vector3(60,2.24,-301),wp(-12,0,18),wp(-12,0,13),wp(-12,0,10),wp(-12,0,13),wp(-12,0,18),Vector3(60,2.24,-301),Vector3(54,2.24,-301),Vector3(46,2.24,-290),Vector3(43,2.24,-274)]:lower.append([p,"dry fin-side G access "+str(p)])
	await fixture(Vector3(43,2.54,-265),lower)
	var checks:Array=[]
	for v in [Vector3(52,2.4,-316),Vector3(60,2.4,-324.8),Vector3(27,2.4,-275)]:
		var q=PhysicsRayQueryParameters3D.create(v,v-Vector3.UP);q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var ok:bool=not hit.is_empty() and absf(hit.position.y-1.54)<.025
		checks.append({"case":"basin not ground or obsolete bridge "+str(v),"valid":ok,"hit":str(hit.get("position"))});if not ok:failures.append(str(v))
	var report={"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":2,"scope":"pond basin/new south perimeter,main approach andG dry access;photo-fitted contour and lawn"}
	FileAccess.open("res://tests/artifacts/library_shore_v118.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_SHORE_V118 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
