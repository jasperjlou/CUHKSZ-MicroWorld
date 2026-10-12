extends "res://tests/StudentCoreV154Clearance.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for y in [4.4,8.8,12.4,16.,19.6]:
		probe(pp(245,650,y-.1),pp(245,650,y+.1),false,"south stair slab opening "+str(y),checks)
		probe(pp(245,614,y+.2),pp(245,614,y-.2),true,"south entry landing "+str(y),checks)
	probe(pp(290,630,1.4),pp(290,650,1.4),true,"service lift stays closed",checks)
	probe(pp(650,480,9.05),pp(650,480,8.65),true,"missing third-floor gallery filled",checks)
	probe(pp(650,450,9.5),pp(650,490,9.5),false,"old guard across circulation removed",checks)
	probe(pp(400,480,9.4),pp(445,480,9.4),true,"gallery drop edge guarded",checks)
	var route:Array=[[pp(245,590,.075),"G south lobby"],[pp(245,614,.015),"G core entry"],[pp(235,614,.015),"G flight alignment"],[pp(235,626,.015),"G first flight"]]
	for i in range(Core154.LEVELS.size()-1):
		var low:float=Core154.LEVELS[i];var high:float=Core154.LEVELS[i+1];var half:float=(low+high)/2
		for q in [[235,672,half],[235,680,half],[256,680,half],[256,672,half],[256,626,high+.015],[256,614,high+.015],[245,614,high+.015],[245,590,high],[245,614,high+.015],[235,614,high+.015],[235,626,high+.015]]:route.append([pp(q[0],q[1],q[2]),"south ascent "+str(i)+" "+str(q)])
	await fixture(pp(400,600,.375),route)
	var down:Array=[]
	for i in range(Core154.LEVELS.size()-1,0,-1):
		var high:float=Core154.LEVELS[i];var low:float=Core154.LEVELS[i-1];var half:float=(low+high)/2
		for q in [[256,614,high+.015],[256,626,high+.015],[256,672,half],[256,680,half],[235,680,half],[235,672,half],[235,626,low+.015],[235,614,low+.015],[245,614,low+.015]]:down.append([pp(q[0],q[1],q[2]),"south descent "+str(i)+" "+str(q)])
	down.append([pp(245,590,.075),"G core out"]);down.append([pp(400,600,.075),"G public hall"])
	await fixture(pp(245,614,19.915),down)
	var gallery:Array=[]
	for q in [[650,450],[650,480],[650,540],[450,580],[400,580],[245,590],[245,614],[245,590],[400,580],[450,580],[650,540],[650,480],[650,450],[650,420]]:gallery.append([pp(q[0],q[1],8.8),"3F court south gallery "+str(q)])
	await fixture(pp(650,420,9.1),gallery)
	await capture("student-v158-south-core",pp(245,614,10.5),pp(235,670,11.3))
	await capture("student-v158-south-lobby",pp(350,588,10.5),pp(245,615,10.3))
	await capture("student-v158-gallery",pp(650,420,10.5),pp(650,550,10.4))
	await capture("student-v158-gallery-edge",pp(380,480,11),pp(650,480,9.7))
	await capture("student-v158-sixth-lobby",pp(325,608,21.3),pp(245,640,21.0))
	FileAccess.open("res://tests/artifacts/student_south_core_v158.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":3,"scope":"South G-6F staircase/lift shell and3F gallery-court interface; historic envelope with fitted compact stairs,not current surveyed dimensions or full building completion."},"\t"))
	print("STUDENT_SOUTH_CORE_V158 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
