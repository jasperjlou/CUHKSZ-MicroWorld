extends "res://tests/LibraryRemoteV112.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var route:Array=[]
	for p in [Vector3(-32.5,0,-20),Vector3(-30,0,-20),Vector3(-30,.36,-22.4),Vector3(-30,.48,-27),Vector3(-30,0,-32),Vector3(-30,.48,-27),Vector3(-30,0,-19),Vector3(-32.5,0,-8)]:route.append([wp(p.x,p.y,p.z),"WC aisle via doorway to rear "+str(p)])
	await fixture(wp(-32.5,.3,-23.8),route)
	await capture("library-remote-v112-stair",rp(1.02,6.1,2.35),rp(-1.02,6.8,-2.2))
	await capture("library-remote-v112-upper-entry",pp(296,432,14.5),pp(204,361,14.3))
	await capture("library-remote-v112-paired-wc",pp(268,208,14.5),pp(196,230,14.2))
	await capture("library-remote-v112-lower",wp(-30.8,1.7,-16.5),wp(-35,1.8,-22))
	FileAccess.open("res://tests/artifacts/library_remote_v112_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"captures":captures,"failures":failures,"fixtures":1,"scope":"Affected rear porch route via actual door; no geometry changes after remote stair validation"},"\t"))
	quit(0 if failures.is_empty() else 1)
