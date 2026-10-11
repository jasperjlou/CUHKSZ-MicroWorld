extends "res://tests/ZhangDatumV137.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true;building=world.builder.buildings.teaching_b
	if DisplayServer.get_name()!="headless":
		await capture("teaching-b-v139-overview",pos(-65,-80,58),pos(0,0,2))
		await capture("teaching-b-v139-lobby",pos(-13,42,2.0),pos(-10,31,2.0))
		await capture("teaching-b-v139-lower",pos(-2,-40,-3),pos(-8,15,-2.8))
		await capture("teaching-b-v139-road",Vector3(-135.12,-.75,-257),Vector3(-135.12,-.75,-289))
		await capture("teaching-b-v139-upper",pos(-25,3,6.5),pos(-19,27,6.4))
		FileAccess.open("res://tests/artifacts/teaching_b_v139_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	var route:Array=[]
	for p:Vector3 in [Vector3(-13,.125,39),Vector3(-13,.125,33),Vector3(-1.4,.125,32.9),Vector3(-1.4,.08,27),Vector3(-8,.08,27),Vector3(-8,.08,26),Vector3(-8,-4.8,9),Vector3(-8,-4.8,-32),Vector3(-13,-4.8,-32),Vector3(-13,-4.8,-41.5),Vector3(-13,-4.565,-48.5),Vector3(38.5,-4.565,-48.5)]:route.append([building.to_global(p),"B lower "+str(p)])
	for p:Vector3 in [Vector3(-135.12,-2.325,-272.5),Vector3(-135.12,-2.325,-286.5),Vector3(-135.12,-2.325,-310),Vector3(-135.12,-2.325,-286.5),Vector3(-135.12,-2.325,-272.5),Vector3(-135.12,-2.325,-258.5)]:route.append([p,"B-C low road "+str(p)])
	for p:Vector3 in [Vector3(38.5,-4.565,-32),Vector3(38.5,.08,-8),Vector3(38.5,.08,49),Vector3(-13,0,49),Vector3(-13,.125,39),Vector3(-13,.125,33)]:route.append([building.to_global(p),"B return "+str(p)])
	await fixture(pos(-13,49,.3),route)
	level_probe("B rear road",0,-50,-4.565)
	level_probe("B lower floor",0,-22,-4.8)
	level_probe("B low wing upper slab",-27,-5,4.75)
	level_probe("B low roof",-27,-5,11.225)
	level_probe("B main roof",-27,-35,18.625)
	probe("B lower stair opening",pos(-8,14,.5),pos(-8,14,-.5),false)
	probe("B outer stair slot",pos(-19.44,12,5.1),pos(-19.44,12,4.3),false)
	probe("B-C underpass clearance",Vector3(-135.12,-.8,-267),Vector3(-135.12,-.8,-278),false)
	FileAccess.open("res://tests/artifacts/teaching_b_v139_physics.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":1,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
