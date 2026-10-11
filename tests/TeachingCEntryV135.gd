extends "res://tests/CardBankRoomV130.gd"
var building:Node3D
func pos(x:float,z:float,y:float=0)->Vector3:return building.to_global(Vector3(x,y,z))
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	building=world.builder.buildings.teaching_c
	if DisplayServer.get_name()!="headless":
		await capture("c-entry-v135-wall",pos(20,44,2.3),pos(26,35.8,2.5))
		await capture("c-entry-v135-glass",pos(18,44,2.2),pos(-5,37,4))
		await capture("c-entry-v135-awning",pos(10,50,2.5),pos(18,46,4))
		await capture("c-entry-v135-threshold",pos(18,40,2.1),pos(15,31,2))
		FileAccess.open("res://tests/artifacts/teaching_c_v135_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	var route:Array=[]
	for p:Vector3 in [Vector3(18,0,44),Vector3(18,0,37),Vector3(18,0,35),Vector3(15,0,31),Vector3(11,0,22),Vector3(15,0,31),Vector3(18,0,35),Vector3(18,0,39),Vector3(25,0,39),Vector3(18,0,39),Vector3(-10,0,39),Vector3(18,0,39),Vector3(18,0,50)]:route.append([building.to_global(p),"C entry public route "+str(p)])
	await fixture(pos(18,50,.3),route)
	probe("C utility wall is solid",pos(25.5,37,1.5),pos(25.5,34,1.5),true)
	probe("C existing doorway clear",pos(18,37,1.5),pos(18,34,1.5),false)
	probe("C opposite glazing retained",pos(0,37,1.5),pos(0,34,1.5),true)
	FileAccess.open("res://tests/artifacts/teaching_c_v135_physics.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":1,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
