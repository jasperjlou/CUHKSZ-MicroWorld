extends "res://tests/ZhangDatumV137.gd"
const P:=preload("res://world/visual_campus/ShawEastPodium.gd")
func wp(x:float,y:float,z:float)->Vector3:return building.to_global(Vector3(x,y,z))
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	building=world.builder.buildings.shaw_east
	if DisplayServer.get_name()!="headless":
		await capture("shaw-plan-v142-side",wp(-43,2.2,2),wp(-28,2,-2))
		await capture("shaw-plan-v142-left-room",wp(-32,2.2,.2),wp(-26,2,-9))
		await capture("shaw-plan-v142-front-room",wp(23.4,2.3,17),wp(12,2,25))
		await capture("shaw-plan-v142-courts",wp(-1,24,21),wp(-4,3,-3))
		await capture("shaw-plan-v142-terrace",wp(1,10.5,3),wp(-14,7,0))
		FileAccess.open("res://tests/artifacts/shaw_plan_v142_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	var points:Array[Vector3]=[
		Vector3(-35.5,.45,0),Vector3(-32,.45,0),Vector3(-26,.45,0),Vector3(-26,.45,-6),
		Vector3(-26,.45,0),Vector3(-32,.45,0),Vector3(-35.5,.45,0),Vector3(-39,0,0),
		Vector3(-39,0,25),Vector3(-33,0,36),Vector3(-20,0,36),
		Vector3(-20,.45,28),Vector3(-20,.45,20),Vector3(-10,.45,20),Vector3(-10,.45,23.3),
		Vector3(0,.45,23.3),Vector3(0,.45,17),Vector3(23.4,.45,17),Vector3(23.4,.45,20.5),
		Vector3(12,.45,20.5),Vector3(12,.45,27),Vector3(12,.45,20.5),Vector3(23.4,.45,20.5),
		Vector3(23.4,.45,17),Vector3(0,.45,17),Vector3(0,.45,23.3),Vector3(-6.1,.45,23.3),
		Vector3(-6.1,2.7,15.4),Vector3(-3.2,2.7,15.4),Vector3(-3.2,4.95,23.3),Vector3(0,4.95,23.3),
		Vector3(0,4.95,14),Vector3(0,8.85,4),Vector3(10,8.85,4),Vector3(10,8.85,-12),
		Vector3(10,8.85,4),Vector3(0,8.85,4),Vector3(0,4.95,14),Vector3(0,4.95,23.3),
		Vector3(-3.2,4.95,23.3),Vector3(-3.2,2.7,15.4),Vector3(-6.1,2.7,15.4),
		Vector3(-6.1,.45,23.3),Vector3(-10,.45,23.3),Vector3(-10,.45,20),Vector3(-20,.45,20),
		Vector3(-20,.45,28),Vector3(-20,0,36)]
	var route:Array=[]
	for p:Vector3 in points:route.append([building.to_global(p),"side/rooms/stairs "+str(p)])
	await fixture(wp(-39,.3,0),route)
	for y:float in [P.F2,P.F3]:
		probe("large court enlarged opening "+str(y),wp(-18.5,y+.3,11.5),wp(-18.5,y-.6,11.5),false)
		probe("small court enlarged opening "+str(y),wp(18.9,y+.3,14.6),wp(18.9,y-.6,14.6),false)
	probe("L room core return wall",wp(15.8,1.9,26),wp(17.8,1.9,26),true)
	probe("L room entrance clear",wp(23.4,1.9,17.8),wp(23.4,1.9,19.4),false)
	probe("side door clear",wp(-35,1.9,0),wp(-33,1.9,0),false)
	probe("obsolete front door is closed",wp(-27,1.9,2.5),wp(-27,1.9,3.5),true)
	FileAccess.open("res://tests/artifacts/shaw_plan_v142_physics.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":1,"failures":failures,"scope":"changed public rooms, side entrance and podium stair/terrace roundtrip; not full dorm fidelity"},"\t"))
	quit(0 if failures.is_empty() else 1)
