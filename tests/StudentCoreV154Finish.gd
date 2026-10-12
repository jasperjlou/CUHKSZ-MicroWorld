extends "res://tests/StudentRegisteredV153.gd"
const Core154=preload("res://world/visual_campus/StudentFrontCore.gd")
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for q in [[118,460],[303,460],[118,563],[303,563],[118,685]]:
		probe(pp(q[0],q[1],.03),pp(q[0],q[1],.3),true,"support foot "+str(q),checks)
		probe(pp(q[0],q[1],16.35),pp(q[0],q[1],15.5),true,"support head "+str(q),checks)
	for y in [4.4,8.8,12.4,16.,19.6]:
		probe(pp(178,56,y-.15),pp(178,56,y+.15),false,"core floor opening "+str(y),checks)
		probe(pp(138,56,y-.2),pp(138,56,y+.2),true,"core entry landing "+str(y),checks)
	probe(pp(360,80,7),pp(360,80,15.5),false,"middle storey notch not capped",checks)
	probe(pp(105,56,1.7),pp(137,56,1.7),false,"core ground entrance",checks)
	probe(pp(185,94,1.4),pp(140,94,1.4),true,"lift stays closed",checks)
	var route:Array=[[pp(137,56,.015),"G core entry"],[pp(137,42,.015),"G flight alignment"],[pp(148,42,.015),"G first flight"]]
	for i in range(Core154.LEVELS.size()-1):
		var low:float=Core154.LEVELS[i];var high:float=Core154.LEVELS[i+1];var half:float=(low+high)/2
		for q in [[208,42,half],[217,42,half],[217,70,half],[208,70,half],[148,70,high+.015],[137,70,high+.015],[137,56,high+.015],[105,56,high],[137,56,high+.015],[137,42,high+.015],[148,42,high+.015]]:
			route.append([pp(q[0],q[1],q[2]),"core ascent "+str(i)+" "+str(q)])
	await fixture(pp(105,56,.375),route)
	var down:Array=[]
	for i in range(Core154.LEVELS.size()-1,0,-1):
		var high:float=Core154.LEVELS[i];var low:float=Core154.LEVELS[i-1];var half:float=(low+high)/2
		for q in [[137,70,high+.015],[148,70,high+.015],[208,70,half],[217,70,half],[217,42,half],[208,42,half],[148,42,low+.015],[137,42,low+.015],[137,56,low+.015]]:
			down.append([pp(q[0],q[1],q[2]),"core descent "+str(i)+" "+str(q)])
	down.append([pp(105,56,.075),"G core exit"])
	await fixture(pp(137,56,19.9),down)
	await capture("student-v154-front-final",pp(-100,590,14),pp(320,460,9))
	await capture("student-v154-core-final",pp(137,56,10.55),pp(205,42,11.5))
	await capture("student-v154-notch-final",pp(365,-50,21),pp(365,190,12))
	await capture("student-v154-sixth-final",pp(110,56,21.2),pp(203,56,21.0))
	FileAccess.open("res://tests/artifacts/student_core_v154_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":2,"scope":"Front historic core G-6F stairs, shared front support grid, upper side notch and affected first court route; not complete campus or site survey"},"\t"))
	print("STUDENT_CORE_V154_FINISH ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
