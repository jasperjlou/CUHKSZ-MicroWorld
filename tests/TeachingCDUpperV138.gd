extends "res://tests/ZhangDatumV137.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true;building=world.builder.buildings.teaching_c
	var route:Array=[]
	for p:Vector3 in [Vector3(-11,.08,28),Vector3(-23,.08,28),Vector3(-23,.08,20),Vector3(-23,.125,15),Vector3(-23,.125,10),Vector3(-19.44,.125,10),Vector3(-19.44,.125,13.62),Vector3(-19.44,4.925,30.62),Vector3(-19.44,4.925,32.32),Vector3(-23,4.925,32.32),Vector3(-23,4.925,30.62),Vector3(-23,3.825,16.26),Vector3(-23,3.825,13),Vector3(-23,3.825,16.26),Vector3(-23,4.925,30.62),Vector3(-23,4.925,32.32),Vector3(-19.44,4.925,32.32),Vector3(-19.44,4.925,30.62),Vector3(-19.44,.125,13.62),Vector3(-23,.125,13.62),Vector3(-23,.08,20),Vector3(-23,.08,28),Vector3(-11,.08,28),Vector3(-11,.08,5),Vector3(-5,.125,3.5),Vector3(2.88,.125,0),Vector3(15,.125,28),Vector3(18,.125,35)]:route.append([building.to_global(p),"C finish "+str(p)])
	await fixture(pos(-11,20,.38),route)
	FileAccess.open("res://tests/artifacts/teaching_cd_v138_upper.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":1,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
