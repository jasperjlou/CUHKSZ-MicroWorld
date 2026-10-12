extends "res://tests/StudentCoreV154Clearance.gd"
func fp(u:float,v:float,y:float)->Vector3:
	var q:=Plan153.fifth_to_first(u,v);return pp(q.x,q.y,y)

func gallery(y:float)->Array:
	var path:Array=[]
	for q in [[720,213],[670,213],[600,213],[550,213],[550,170],[550,130],[550,213],[450,213],[450,170],[450,130],[450,213],[390,213],[320,213],[280,213],[320,213],[450,213],[600,213],[670,213],[720,213]]:
		path.append([fp(q[0],q[1],y),"upper gallery "+str(y)+" "+str(q)])
	path.append([pp(720,95,y),"return to rear core "+str(y)])
	return path

func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for y in [4.4,8.8,12.4,16.,19.6]:
		probe(pp(750,53,y-.1),pp(750,53,y+.1),false,"rear core slab opening "+str(y),checks)
		probe(pp(720,56,y+.2),pp(720,56,y-.2),true,"rear core landing "+str(y),checks)
	for y in [16.,19.6]:
		for u in [350.,630.]:
			probe(fp(u,213,y+.2),fp(u,213,y-.2),true,"gallery gap floor "+str([u,y]),checks)
			probe(fp(u,220,y+.6),fp(u,255,y+.6),true,"gallery outer guard "+str([u,y]),checks)
		probe(fp(470,140,y+1.4),fp(515,140,y+1.4),true,"middle room divider "+str(y),checks)
		probe(fp(280,213,y+1.4),fp(330,213,y+1.4),false,"front wing portal "+str(y),checks)
		probe(fp(670,213,y+1.4),fp(720,213,y+1.4),false,"rear wing portal "+str(y),checks)
	var route:Array=[[pp(720,95,.075),"G vestibule"],[pp(720,56,.015),"G core entry"],[pp(720,40,.015),"G flight alignment"],[pp(730,40,.015),"G first flight"]]
	for i in range(Core154.LEVELS.size()-1):
		var low:float=Core154.LEVELS[i];var high:float=Core154.LEVELS[i+1];var half:float=(low+high)/2
		for q in [[778,40,half],[786,40,half],[786,66,half],[778,66,half],[730,66,high+.015],[720,66,high+.015],[720,95,high]]:
			route.append([pp(q[0],q[1],q[2]),"rear core ascent "+str(i)+" "+str(q)])
		if high>=16:route.append_array(gallery(high))
		if high<19.6:
			for q in [[720,56,high+.015],[720,40,high+.015],[730,40,high+.015]]:route.append([pp(q[0],q[1],q[2]),"next flight "+str(q)])
	await fixture(pp(690,110,.375),route)
	var down:Array=[]
	for i in range(Core154.LEVELS.size()-1,0,-1):
		var high:float=Core154.LEVELS[i];var low:float=Core154.LEVELS[i-1];var half:float=(low+high)/2
		for q in [[720,66,high+.015],[730,66,high+.015],[778,66,half],[786,66,half],[786,40,half],[778,40,half],[730,40,low+.015],[720,40,low+.015],[720,56,low+.015]]:
			down.append([pp(q[0],q[1],q[2]),"rear core descent "+str(i)+" "+str(q)])
	down.append([pp(690,110,.075),"G rear core exit"])
	await fixture(pp(720,95,19.9),down)
	await capture("student-v156-gallery",fp(310,214,17.8),fp(735,214,17.5))
	await capture("student-v156-rear-core",pp(720,96,10.55),pp(776,40,11.4))
	await capture("student-v156-gallery-overview",pp(550,400,29),pp(530,200,16))
	await capture("student-v156-middle-room",fp(452,120,17.8),fp(452,230,17.5))
	await capture("student-v156-front",pp(-110,630,17),pp(480,360,10))
	FileAccess.open("res://tests/artifacts/student_rear_core_v156.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":2,"scope":"Rear core G-6F,5F/6F upper gallery and two room entrances; historic plan with fitted levels,not whole campus or current-site fidelity"},"\t"))
	print("STUDENT_REAR_CORE_V156 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
