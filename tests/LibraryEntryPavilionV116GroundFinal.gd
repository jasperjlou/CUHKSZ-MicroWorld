extends "res://tests/LibraryEntryPavilionV116Finish.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false)
	var route:Array=[]
	for p in [Vector3(43,0,7),Vector3(40,0,9),Vector3(37,0,6),Vector3(35,0,3)]:route.append([wp(p.x,p.y,p.z),"G route outside silent-cell bodies "+str(p)])
	await fixture(wp(43,.3,5),route)
	var report={"version":world.data.version,"physical_legs":legs,"checks":[],"failures":failures,"fixtures":1,"scope":"G end route continued around existing S101/S102 booths; no geometry or acceptance tolerance changes"}
	FileAccess.open("res://tests/artifacts/library_entry_pavilion_v116_ground_final.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_ENTRY_GROUND ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
