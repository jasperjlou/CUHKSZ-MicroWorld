extends "res://tests/ZhangTiersV133.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	building=world.builder.buildings.zhang_lingbin
	if DisplayServer.get_name()!="headless":
		await capture("zhang-tiers-v133-overview",pos(0,70,135),pos(0,0))
		await capture("zhang-tiers-v133-court",pos(-8,16,3),pos(-24,-8,12))
		await capture("zhang-tiers-v133-through-entry",pos(3,34.2,1.7),pos(0,-20,2.0))
		FileAccess.open("res://tests/artifacts/zhang_tiers_v133_finish_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	var route:Array=[]
	for p:Vector3 in [Vector3(3,0,38),Vector3(3,0,34.64),Vector3(3,0,32.84),Vector3(0,0,32.84),Vector3(0,0,17),Vector3(0,0,8.64),Vector3(0,0,0),Vector3(0,0,-20),Vector3(0,0,-46),Vector3(0,0,-20),Vector3(0,0,8.64),Vector3(0,0,32.84),Vector3(3,0,32.84),Vector3(3,0,38),Vector3(3,0,42.64)]:route.append([building.to_global(p),"entry court rear roundtrip "+str(p)])
	await fixture(pos(3,42.64,.3),route)
	probe("obsolete inner door pier removed",pos(2.1,10.8,1.7),pos(2.1,7.5,1.7),false)
	FileAccess.open("res://tests/artifacts/zhang_tiers_v133_finish_physics.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":1,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
