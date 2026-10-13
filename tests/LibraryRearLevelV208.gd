extends "res://tests/LibraryLowerRearV150.gd"
const Road208=preload("res://world/visual_campus/LibraryRearRoad.gd")
const Bank208=preload("res://world/visual_campus/RearRoadBank.gd")
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(dp(0,6.1,-1),dp(0,6.1,1),false,"2F rear doorway open",checks)
	probe(dp(0,6.1,3),dp(0,6.1,4),true,"staff vestibule boundary retained",checks)
	probe(dp(0,2,-1),dp(0,2,1),true,"retired G exterior portal closed",checks)
	probe(wp(-30,2,-20.4),wp(-30,2,-21.5),true,"G public aisle end enclosed",checks)
	probe(wp(-30,1,-18.5),wp(-30,-.2,-18.5),true,"G toilet aisle retains lower support",checks)
	var route:Array=[]
	for v in [[0,3.92,-7],[0,3.92,-5.6],[0,4.4,-3],[0,4.4,-.5],[0,4.4,2],[0,4.4,-.5],[0,4.4,-2.4],[3.8,4.4,-2.4],[8,4.16,-2.4],[12.5,3.92,-2.4],[8,4.16,-2.4],[3.8,4.4,-2.4],[0,4.4,-2.4],[0,3.92,-5.6],[0,3.92,-7]]:route.append([dp(v[0],v[1],v[2]),"2F rear door stair/ramp "+str(v)])
	await fixture(dp(0,4.22,-9),route)
	var avenue:Array=[]
	for p in [[127,-350],[132,-330],[137,-310],[137,-290],[137,-270],[137,-290],[137,-310],[132,-330],[127,-350]]:
		avenue.append([Vector3(p[0],Road208.rear_avenue_height(p[1]),p[1]),"rear avenue profile "+str(p)])
	await fixture(Vector3(127,Road208.rear_avenue_height(-350)+.4,-350),avenue)
	var points:Array=[]
	for r:Dictionary in world.data.routes:
		if r.id=="library_rear_shaw_avenue":points=r.points
	var x:float=Bank208.toe(-313,points);var y:float=Bank208.road_height(-313)
	await fixture(Vector3(x-.7,y+.4,-313),[[Vector3(x,y,-313),"bank stair toe"],[Vector3(x+4.2,y+3.4,-313),"bank upper landing"],[Vector3(x,y,-313),"bank descent"],[Vector3(x-.7,y,-313),"bank return"]])
	root.disable_3d=false;await frames(12)
	await capture("library-rear-v208-overall",wp(-53,16,-60),wp(-21,9,-30))
	await capture("library-rear-v208-porch",dp(-8,7.2,-10),dp(3,5.9,-1))
	await capture("library-rear-v208-road",Vector3(130,10,-345),Vector3(138,8,-285))
	await capture("library-rear-v208-g-aisle",wp(-30,1.8,-15),wp(-30,1.8,-21))
	FileAccess.open("res://tests/artifacts/library_rear_level_v208.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"scope":"2F staff porch, changed rear avenue, linked bank stair and G aisle closure; fitted grade, no campus-wide survey"},"\t"))
	print("LIBRARY_REAR_LEVEL_V208 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
