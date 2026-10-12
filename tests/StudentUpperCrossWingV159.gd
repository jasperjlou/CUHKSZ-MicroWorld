extends "res://tests/StudentRearCoreV156.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(fp(500,330,19.8),fp(500,330,19.4),true,"new upper wing floor",checks)
	probe(fp(500,330,16.1),fp(500,330,15.9),false,"5F remains open below upper wing",checks)
	probe(fp(550,220,21.0),fp(550,260,21.0),false,"upper north connection",checks)
	probe(fp(550,420,21.0),fp(550,460,21.0),false,"upper south connection",checks)
	probe(fp(390,330,21),fp(430,330,21),true,"front yellow glazing retains collision",checks)
	probe(fp(570,330,21),fp(610,330,21),true,"back yellow glazing retains collision",checks)
	probe(fp(550,420,17.4),fp(550,460,17.4),true,"5F south edge remains closed",checks)
	probe(fp(550,230,16.6),fp(550,250,16.6),true,"5F gallery drop still guarded",checks)
	probe(fp(550,170,17.4),fp(550,200,17.4),false,"5F room doorway remains open",checks)
	var route:Array=[]
	for q in [[390,213],[450,213],[550,213],[550,260],[550,330],[550,410],[550,470],[500,520],[450,570]]:route.append([fp(q[0],q[1],19.6),"upper wing outward "+str(q)])
	for q in [[350,590],[245,590],[245,614],[245,590],[350,590]]:route.append([pp(q[0],q[1],19.6),"south core interface "+str(q)])
	for q in [[450,570],[500,520],[550,470],[450,470],[450,410],[450,330],[450,260],[450,213],[600,213],[670,213],[720,213]]:route.append([fp(q[0],q[1],19.6),"upper wing return "+str(q)])
	for q in [[720,95],[720,66],[720,95]]:route.append([pp(q[0],q[1],19.6),"rear core interface "+str(q)])
	for q in [[720,213],[670,213],[600,213],[450,213],[390,213],[280,213]]:route.append([fp(q[0],q[1],19.6),"gallery return "+str(q)])
	await fixture(fp(280,213,19.9),route)
	await capture("student-v159-court-front",fp(320,334,13.8),fp(550,334,19.0))
	await capture("student-v159-court-back",fp(760,334,14),fp(470,334,19.1))
	await capture("student-v159-inside",fp(500,260,21.3),fp(500,430,21.2))
	await capture("student-v159-roof",fp(480,490,36),fp(500,334,19.6))
	await capture("student-v159-south-joint",fp(550,480,21.3),fp(550,330,21.2))
	FileAccess.open("res://tests/artifacts/student_upper_cross_wing_v159.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Photo-informed upper cross-court volume and affected upper circulation; storey and footprint inference,not independent6F plan or whole-campus completion."},"\t"))
	print("STUDENT_UPPER_CROSS_V159 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
