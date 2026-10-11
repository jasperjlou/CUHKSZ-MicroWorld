extends "res://tests/ZhangDatumV137.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true;building=world.builder.buildings.zhang_lingbin
	var route:Array=[]
	for p:Vector3 in [Vector3(-20.4,.125,-26.6),Vector3(-20.4,.125,-22.5),Vector3(-24.4,.125,-20),Vector3(-24.4,.125,12),Vector3(-21.5,.125,15),Vector3(-21.5,.125,20),Vector3(3,.08,25),Vector3(3,0,42)]:route.append([building.to_global(p),"core exit "+str(p)])
	await fixture(pos(-21.65,-26.6,.425),route)
	FileAccess.open("res://tests/artifacts/zhang_datum_v137_exit.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":1,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
