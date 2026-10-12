extends "res://tests/LibraryRearAccessV180.gd"
const Bank182=preload("res://world/visual_campus/RearRoadBank.gd")

func gp182(x:float,z:float)->Vector3:
	return Vector3(x,world.builder.height(x,z),z)

func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var route:Array=[]
	for p:Vector2 in [Vector2(116,-410),Vector2(116,-390),Vector2(116,-372),Vector2(127,-350),Vector2(137,-310),Vector2(137,-285),Vector2(137,-265)]:
		route.append([gp182(p.x,p.y),"rear avenue through retained terrain "+str(p)])
	await fixture(gp182(116,-425)+Vector3.UP*.3,route)
	var x:float=Bank182.toe(Bank182.STAIR_Z,world.builder.rear_route)
	var y:float=Bank182.road_height(Bank182.STAIR_Z)
	await fixture(Vector3(x-1,y+.3,Bank182.STAIR_Z),[[Vector3(x+.2,y+.2,Bank182.STAIR_Z),"bank stair foot"],[Vector3(x+Bank182.RUN+.7,y+Bank182.RISE+.04,Bank182.STAIR_Z),"bank stair top remains clear"],[Vector3(x+.2,y+.2,Bank182.STAIR_Z),"return down bank stair"],[Vector3(x-1,y,Bank182.STAIR_Z),"back to road edge"]])
	var checks:Array=[]
	for p:Vector2 in [Vector2(150,-395),Vector2(170,-310),Vector2(205,-270)]:
		var surface:Vector3=gp182(p.x,p.y)
		probe(surface+Vector3.UP*1.5,surface-Vector3.UP*1.5,true,"forest soil retained support "+str(p),checks)
	var edge:Node=world.get_node("LibraryStudentWoodlandEdgeV182")
	var counts:Dictionary=edge.get_meta("counts")
	var obstacles:int=edge.find_children("*","CollisionShape3D",true,false).size()
	checks.append({"case":"visual planting adds no physical obstacles","valid":obstacles==0})
	if obstacles!=0:failures.append("planting changed collision")
	root.disable_3d=false;await frames(15)
	await capture("ground-v182-library-bank",Vector3(128,7,-356),Vector3(157,9,-296))
	await capture("ground-v182-student-road",Vector3(113,4.2,-421),Vector3(137,5.5,-375))
	await capture("ground-v182-bank-stair",Vector3(x-8,y+2.2,Bank182.STAIR_Z-5),Vector3(x+4,y+4,Bank182.STAIR_Z))
	await capture("ground-v182-central-overall",Vector3(-10,68,-465),Vector3(123,11,-330))
	FileAccess.open("res://tests/artifacts/woodland_ground_v182.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"failures":failures,"captures":captures,"fixtures":2,"planting":counts,"scope":"C-D rear-road forest margin and unchanged terrain support; not full A-G ground release gate"},"\t"))
	print("WOODLAND_V182 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures,"planting":counts}));quit(0 if failures.is_empty() else 1)
