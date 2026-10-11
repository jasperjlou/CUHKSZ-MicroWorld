extends "res://tests/ZhangDatumV137.gd"
func wp(x:float,y:float,z:float)->Vector3:return building.to_global(Vector3(x,y,z))
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	building=world.builder.buildings.shaw_west.get_node("WestPlanFrameV143")
	if DisplayServer.get_name()!="headless":
		await capture("shaw-west-v143-plan",wp(45,75,52),wp(-10,10,-2))
		await capture("shaw-west-v143-entry",wp(-10,5,37),wp(6,5,24))
		await capture("shaw-west-v143-return-stair",wp(-7,9,33),wp(1,5,27))
		await capture("shaw-west-v143-courts",wp(-5,100,10),wp(-9,0,-5))
		await capture("shaw-west-v143-hall",wp(2.8,10.4,-10),wp(-1,10.4,-24))
		FileAccess.open("res://tests/artifacts/shaw_west_v143_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	var pts:Array[Vector3]=[
		Vector3(9,.05,32),Vector3(9,.05,28.7),Vector3(3.6,.05,28.7),Vector3(-2.9,2.225,28.7),Vector3(-2.9,2.225,26),Vector3(4.8,4.4,26),
		Vector3(7,4.4,26),Vector3(7,4.4,28.7),Vector3(3.6,4.4,28.7),Vector3(-2.9,6.6,28.7),Vector3(-2.9,6.6,26),Vector3(4.8,8.8,26),
		Vector3(9,8.8,26),Vector3(9,8.8,10),Vector3(7,8.8,5),Vector3(5,8.8,-5),Vector3(-12,8.8,-5),Vector3(-18,8.8,-5),
		Vector3(-12,8.8,-5),Vector3(2.8,8.8,-5),Vector3(2.8,8.8,-9),Vector3(2.8,8.8,-25),Vector3(2.8,8.8,-9),Vector3(2.8,8.8,-5),
		Vector3(5,8.8,-5),Vector3(7,8.8,5),Vector3(9,8.8,10),Vector3(9,8.8,26),Vector3(4.8,8.8,26),Vector3(-2.9,6.6,26),
		Vector3(-2.9,6.6,28.7),Vector3(3.6,4.4,28.7),Vector3(7,4.4,28.7),Vector3(7,4.4,26),Vector3(4.8,4.4,26),
		Vector3(-2.9,2.225,26),Vector3(-2.9,2.225,28.7),Vector3(3.6,.05,28.7),Vector3(9,.05,28.7),Vector3(9,.05,32),Vector3(9,0,36)]
	var route:Array=[]
	for p:Vector3 in pts:route.append([building.to_global(p),"plan route "+str(p)])
	await fixture(wp(9,.3,36),route)
	for y:float in [4.4,8.8,12.1]:
		probe("large court open "+str(y),wp(-14,y+.3,-15),wp(-14,y-.6,-15),false)
		probe("small court open "+str(y),wp(-1.5,y+.3,3),wp(-1.5,y-.6,3),false)
	probe("3Fhall boundary",wp(-4,10,-20),wp(-6,10,-20),true)
	probe("3Fhall entry",wp(2.8,10,-5),wp(2.8,10,-9),false)
	probe("switchback outside guard",wp(-2.9,2.8,27),wp(-4.5,2.8,27),true)
	FileAccess.open("res://tests/artifacts/shaw_west_v143_physics.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":1,"failures":failures,"scope":"registered public3F/courts and external switchback only; private/roof core and absolute site dimensions not accepted"},"\t"))
	quit(0 if failures.is_empty() else 1)

