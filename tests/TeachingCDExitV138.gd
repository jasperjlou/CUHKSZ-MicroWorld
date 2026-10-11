extends "res://tests/TeachingCDDatumV138.gd"
func run()->void:
	if DisplayServer.get_name()!="headless":await super.run();return
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true;building=world.builder.buildings.teaching_c
	var route:Array=[]
	for p:Vector3 in [Vector3(-23,.08,28),Vector3(-11,.08,28),Vector3(-11,.08,5),Vector3(-5,.125,3.5),Vector3(2.88,.125,0),Vector3(15,.125,28),Vector3(18,.125,35),Vector3(18,0,44)]:route.append([building.to_global(p),"C final exit "+str(p)])
	await fixture(pos(-23,20,.38),route)
	probe("C branch guard no longer blocks turn",pos(38.5,-48.5,-3.5),pos(38.5,-42,-3.5),false)
	FileAccess.open("res://tests/artifacts/teaching_cd_v138_exit.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":1,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
