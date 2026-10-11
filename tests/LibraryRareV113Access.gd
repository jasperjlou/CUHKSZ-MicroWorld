extends "res://tests/LibraryRareV113.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false)
	var route:Array=[[pp(625,710,16.8),"4F stair arrives at5F diagonal bridge"]]
	for p in [[615,710],[615,750],[600,790],[585,800],[560,806],[541,795],[510,794],[470,794],[470,780]]:route.append([pp(p[0],p[1],16.8),"final platform to shortened flight "+str(p)])
	await fixture(pp(470,710,15.1),route)
	FileAccess.open("res://tests/artifacts/library_rare_v113_access.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"failures":failures,"fixtures":1},"\t"))
	quit(0 if failures.is_empty() else 1)
