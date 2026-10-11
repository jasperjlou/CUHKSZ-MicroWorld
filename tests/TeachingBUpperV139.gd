extends "res://tests/ZhangDatumV137.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true;building=world.builder.buildings.teaching_b
	var route:Array=[]
	for p:Vector3 in [Vector3(-13,.125,33),Vector3(-13,.125,25),Vector3(-13,.125,3),Vector3(-19.44,.125,3),Vector3(-19.44,.125,7.04),Vector3(-19.44,4.925,24.04),Vector3(-19.44,4.925,27.04),Vector3(-25,4.925,27.04),Vector3(-25,4.75,20),Vector3(-25,4.75,-15),Vector3(-25,4.75,20),Vector3(-25,4.925,27.04),Vector3(-19.44,4.925,27.04),Vector3(-19.44,4.925,40.44),Vector3(-24,4.925,40.44),Vector3(-19.44,4.925,40.44),Vector3(-19.44,4.925,27.04),Vector3(-19.44,4.925,24.04),Vector3(-19.44,.125,7.04),Vector3(-19.44,.125,3),Vector3(-13,.125,3),Vector3(-13,.125,25),Vector3(-13,.125,33),Vector3(-13,0,42)]:route.append([building.to_global(p),"B upper "+str(p)])
	await fixture(pos(-13,42,.3),route)
	await fixture(Vector3(-145,2.54,-272.5),[[Vector3(-135.12,2.32,-272.5),"upper transverse bridge"],[Vector3(-125,2.24,-272.5),"bridge to mall side"],[Vector3(-145,2.24,-272.5),"upper bridge return"]])
	probe("B front upper door open",pos(-19.44,34,6),pos(-19.44,37,6),false)
	FileAccess.open("res://tests/artifacts/teaching_b_v139_upper.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":2,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
