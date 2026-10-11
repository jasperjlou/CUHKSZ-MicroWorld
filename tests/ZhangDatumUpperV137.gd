extends "res://tests/ZhangDatumV137.gd"
func run()->void:
	if DisplayServer.get_name()!="headless":await super.run();return
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true;building=world.builder.buildings.zhang_lingbin
	var route:Array=[]
	for p:Vector3 in [Vector3(3,0,49),Vector3(15,0,49),Vector3(15,0,44.49),Vector3(12,0,44.49),Vector3(-5,4.925,44.49),Vector3(-21.5,4.925,41.24),Vector3(-21.5,4.925,39.64),Vector3(-21.5,3.825,16.26),Vector3(-24.4,3.825,12),Vector3(-24.4,3.825,-20),Vector3(-20.4,3.825,-22.5),Vector3(-20.4,3.825,-26.6),Vector3(-21.65,3.825,-26.6),Vector3(-21.65,5.675,-39.1),Vector3(-19.15,5.675,-39.1),Vector3(-19.15,7.525,-26.6),Vector3(-24.4,7.525,-20),Vector3(-24.4,7.525,12),Vector3(-21.5,7.525,15),Vector3(-21.5,8.625,39.64),Vector3(-21.5,8.625,41.24),Vector3(-21.5,8.625,39.64),Vector3(-21.5,7.525,15),Vector3(-24.4,7.525,12),Vector3(-24.4,7.525,-20),Vector3(-19.15,7.525,-26.6),Vector3(-19.15,5.675,-39.1),Vector3(-21.65,5.675,-39.1),Vector3(-21.65,3.825,-26.6),Vector3(-19.15,3.825,-26.6),Vector3(-19.15,1.975,-39.1),Vector3(-21.65,1.975,-39.1),Vector3(-21.65,.125,-26.6),Vector3(-20.4,.125,-26.6),Vector3(-20.4,.125,-22.5),Vector3(-24.4,.125,-20),Vector3(-24.4,.125,12),Vector3(-21.5,.125,15),Vector3(-21.5,.125,20),Vector3(3,.08,25),Vector3(3,0,42)]:route.append([building.to_global(p),"upper datum loop "+str(p)])
	await fixture(pos(3,42,.3),route)
	FileAccess.open("res://tests/artifacts/zhang_datum_v137_upper.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":1,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
