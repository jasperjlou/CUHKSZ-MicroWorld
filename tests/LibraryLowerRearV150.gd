extends "res://tests/LibraryCoreBoundaryV147Finish.gd"
const Rear150=preload("res://world/visual_campus/LibraryLowerRearEnvelope.gd")
const LowerP=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
func dp(x:float,y:float,z:float)->Vector3:
	var p:=Rear150.door_point(Vector3(x,y,z));return wp(p.x,p.y,p.z)
func p3(x:float,z:float,y:float)->Vector3:
	var p:=LowerP.point3(x,z,y);return wp(p.x,p.y,p.z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(dp(0,1.8,-1),dp(0,1.8,1),false,"relocated rear doorway open",checks)
	probe(dp(-5,1.8,-1),dp(-5,1.8,1),true,"G rear masonry closed",checks)
	probe(dp(5,6.2,-1),dp(5,6.2,1),true,"2F rear masonry closed",checks)
	probe(wp(-35,2,-26),wp(-35,2,-24.4),false,"old rear wall removed",checks)
	for i in [1,3]:
		var a:=Rear150.point(Rear150.THIRD[i],3);var b:=Rear150.point(Rear150.THIRD[i+1],3);var mid:Vector3=(a+b)/2;var d:Vector3=(b-a).normalized();var normal:=Vector3(-d.z,0,d.x)
		probe(wp(mid.x-normal.x,10.2,mid.z-normal.z),wp(mid.x+normal.x,10.2,mid.z+normal.z),false,"3F mapped terrace door "+str(i),checks)
	var route:Array=[]
	for v in [[0,0,-5.6],[0,.48,-3.1],[0,.48,-.5],[0,.48,1.8],[0,0,4.8],[0,0,8],[0,0,12],[0,0,14]]:route.append([dp(v[0],v[1],v[2]),"new rear porch/public vestibule "+str(v)])
	route.append([wp(-30,0,-14.4),"rear vestibule to retained G aisle"])
	await fixture(dp(0,.3,-7.8),route)
	var terrace:Array=[]
	for v in [[570,190],[590,160],[640,160],[720,160],[760,200],[850,275],[945,300],[960,342],[910,375]]:terrace.append([p3(v[0],v[1],8.8),"registered3F indoor/outdoor boundary "+str(v)])
	await fixture(p3(545,190,9.1),terrace)
	await capture("library-lower-rear-v150-masonry",wp(-53,15,-60),wp(-21,6,-27))
	await capture("library-lower-rear-v150-portal",dp(-9,3.5,-11),dp(0,2,0))
	await capture("library-lower-rear-v150-vestibule",dp(0,1.75,10),dp(0,1.75,-2))
	await capture("library-lower-rear-v150-terrace",p3(790,130,11),p3(630,235,10.6))
	await capture("library-lower-rear-v150-overall",wp(-35,37,-72),wp(-3,10,-18))
	FileAccess.open("res://tests/artifacts/library_lower_rear_v150.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":2,"scope":"Changed rearGvestibule and3Fterrace only;G service enclosure/grade hypothesis not surveyed"},"\t"))
	print("LIBRARY_LOWER_REAR_V150 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}))
	quit(0 if failures.is_empty() else 1)
