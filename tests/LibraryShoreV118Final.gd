extends "res://tests/LibraryEntryApproachV117.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-shore-v118-final-overview",Vector3(-1,33,-226),Vector3(65,8,-290))
	await capture("library-shore-v118-final-lawn",ap(27,45,12),ap(5,15,3.5))
	await capture("library-shore-v118-final-soffit",ap(0,7,1.3),ap(0,2.5,2.8))
	var lawn=preload("res://world/visual_campus/LibraryEntryLawn.gd");var route:Array=[]
	for z in [35.0,27.0,19.0,12.0,19.0,27.0,35.0]:
		var p:Vector3=Approach.point(lawn.outer(z)+1.0,z,.135);route.append([wp(p.x,p.y,p.z),"corrected exterior lawn walk "+str(z)])
	var start:Vector3=Approach.point(lawn.outer(37)+1.0,37,.435);await fixture(wp(start.x,start.y,start.z),route)
	var report={"version":world.data.version,"physical_legs":legs,"captures":captures,"failures":failures,"fixtures":1,"scope":"outer path moved clear of pavilion corner; photographic surface/soffit review; retained prior unaffected basin/G/main approach checks"}
	FileAccess.open("res://tests/artifacts/library_shore_v118_final.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_SHORE_V118_FINAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
