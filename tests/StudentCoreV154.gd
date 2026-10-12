extends "res://tests/StudentRegisteredV153.gd"
const Core154=preload("res://world/visual_campus/StudentFrontCore.gd")
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for q in [[118,460],[303,460],[118,563],[303,563],[118,685]]:
		probe(pp(q[0],q[1],.03),pp(q[0],q[1],.3),true,"support foot "+str(q),checks)
		probe(pp(q[0],q[1],15.5),pp(q[0],q[1],16.3),true,"support head "+str(q),checks)
	for y in [4.4,8.8,12.4,16.,19.6]:
		probe(pp(178,56,y-.15),pp(178,56,y+.15),false,"core floor opening "+str(y),checks)
		probe(pp(138,56,y-.2),pp(138,56,y+.2),true,"core entry landing "+str(y),checks)
	probe(pp(360,80,7),pp(360,80,15.5),false,"middle storey notch not capped",checks)
	probe(pp(105,56,1.7),pp(137,56,1.7),false,"core ground entrance",checks)
	probe(pp(140,94,1.4),pp(178,94,1.4),true,"lift stays closed",checks)
	var route:Array=[[pp(137,56,.015),"G core entry"],[pp(148,42,.015),"G first flight"]]
	for i in range(Core154.LEVELS.size()-1):
		var low:float=Core154.LEVELS[i];var high:float=Core154.LEVELS[i+1];var half:float=(low+high)/2
		for q in [[208,42,half],[217,42,half],[217,70,half],[208,70,half],[148,70,high+.015],[137,70,high+.015],[137,56,high+.015],[105,56,high],[137,56,high+.015],[148,42,high+.015]]:
			route.append([pp(q[0],q[1],q[2]),"core ascent "+str(i)+" "+str(q)])
	await fixture(pp(105,56,.375),route)
	var down:Array=[]
	for i in range(Core154.LEVELS.size()-1,0,-1):
		var high:float=Core154.LEVELS[i];var low:float=Core154.LEVELS[i-1];var half:float=(low+high)/2
		for q in [[137,70,high+.015],[148,70,high+.015],[208,70,half],[217,70,half],[217,42,half],[208,42,half],[148,42,low+.015],[137,42,low+.015],[137,56,low+.015]]:
			down.append([pp(q[0],q[1],q[2]),"core descent "+str(i)+" "+str(q)])
	down.append([pp(105,56,.075),"G core exit"])
	await fixture(pp(137,56,19.9),down)
	await fixture(Vector3(36,6.94,-400),[[pp(85,475,4.4),"bridge before front column"],[pp(145,475,4.4),"around first support"],[pp(275,485,4.4),"first court aisle"],[pp(335,485,4.4),"around second support"],[pp(350,458,4.4),"first court onward"],[pp(400,430,4.4),"middle stair remains accessible"],[pp(555,430,8.8),"middle stair ascent"]])
	await capture("student-v154-front",pp(-100,590,14),pp(320,460,9))
	await capture("student-v154-core",pp(137,56,10.55),pp(205,42,11.5))
	await capture("student-v154-notch",pp(365,-50,21),pp(365,190,12))
	await capture("student-v154-sixth",pp(105,130,21.3),pp(180,52,21.0))
	FileAccess.open("res://tests/artifacts/student_core_v154.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":3,"scope":"Front historic core G-6F stairs, shared front support grid, upper side notch and affected first court route; not complete campus or site survey"},"\t"))
	print("STUDENT_CORE_V154 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
