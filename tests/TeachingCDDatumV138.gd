extends "res://tests/ZhangDatumV137.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true;building=world.builder.buildings.teaching_c
	if DisplayServer.get_name()!="headless":
		await capture("teaching-cd-v138-overview",pos(-62,-78,52),pos(0,-5,0))
		await capture("teaching-cd-v138-lower",pos(-4,-40,-3),pos(-8,14,-2.5))
		await capture("teaching-cd-v138-road",pos(27,-52,-2.8),pos(55,-48,-2.8))
		await capture("teaching-cd-v138-entry",pos(22,49,3.1),pos(15,29,2))
		await capture("teaching-cd-v138-bridge",pos(-26,26,6.3),pos(-23,12,5.1))
		FileAccess.open("res://tests/artifacts/teaching_cd_v138_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	var route:Array=[]
	for p:Vector3 in [Vector3(18,.125,35),Vector3(15,.125,28),Vector3(2.88,.125,0),Vector3(-5,.125,3.5),Vector3(-11,.08,5),Vector3(-11,.08,30),Vector3(-8,.08,30),Vector3(-8,.08,28),Vector3(-8,-4.8,9),Vector3(-8,-4.8,-32),Vector3(-13,-4.8,-32),Vector3(-13,-4.8,-41.5),Vector3(-13,-4.565,-48.5),Vector3(38.5,-4.565,-48.5)]:route.append([building.to_global(p),"C lower loop "+str(p)])
	route.append([Vector3(-131.14,-2.325,-381.5),"continuous C-D low connector"])
	route.append([Vector3(-131.14,-2.325,-408),"D rear road approach"])
	route.append([Vector3(-131.14,-2.325,-381.5),"D rear return"])
	for p:Vector3 in [Vector3(38.5,-4.565,-48.5),Vector3(-40.5,-4.565,-48.5),Vector3(-49.5,.08,-48.5),Vector3(-40.5,-4.565,-48.5),Vector3(38.5,-4.565,-48.5),Vector3(38.5,-4.565,-32),Vector3(38.5,.08,-8),Vector3(38.5,.08,49),Vector3(18,.08,49),Vector3(18,.125,35)]:route.append([building.to_global(p),"C road return "+str(p)])
	await fixture(pos(18,44,.3),route)
	level_probe("C rear road grade",0,-50,-4.565)
	level_probe("C lower floor",0,-22,-4.8)
	level_probe("C upper platform",-11,10,.08)
	level_probe("C low roof",-24.4,10,7.525)
	level_probe("C main roof",-27,-35,18.625)
	probe("lower rear doorway",pos(-13,-45,-3),pos(-13,-42,-3),false)
	probe("lower stair opening",pos(-8,14,.5),pos(-8,14,-.5),false)
	FileAccess.open("res://tests/artifacts/teaching_cd_v138_physics.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":1,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
