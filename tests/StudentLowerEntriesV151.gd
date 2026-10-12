extends "res://tests/LibraryCoreBoundaryV147Finish.gd"
func wp(x:float,y:float,z:float)->Vector3:
	return Vector3(91.5-z,2.24+y,-400+x)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for x in [-9.6,-24.0]:probe(wp(x,1.6,-50),wp(x,1.6,-44),false,"side rear entry clear "+str(x),checks)
	probe(wp(0,1.6,-49),wp(0,1.6,-45),true,"retired centre rear opening sealed",checks)
	probe(wp(-9.6,1.6,-42.5),wp(-12,1.6,-42.5),true,"lobby service door stays closed",checks)
	for x in [-4.8,3.6]:probe(wp(x,1.6,14),wp(x,1.6,10),false,"lower yellow court entry clear "+str(x),checks)
	probe(wp(-.6,1.6,14),wp(-.6,1.6,10),true,"neighbour court window retains collision",checks)
	probe(wp(-9.6,3.8,-40.4),wp(-9.6,4.4,-40.4),true,"rear lobby soffit present",checks)
	var rear:Array=[]
	for p in [Vector3(-9.6,0,-53.5),Vector3(-9.6,0,-49),Vector3(-9.6,0,-45),Vector3(-9.6,0,-38),Vector3(-9.6,0,-32),Vector3(-9.6,0,-38),Vector3(-9.6,0,-49),Vector3(-9.6,0,-53.5),Vector3(-24,0,-53.5),Vector3(-24,0,-49),Vector3(-24,0,-44),Vector3(-24,0,-49),Vector3(-24,0,-53.5)]:rear.append([wp(p.x,p.y,p.z),"rear doors and lobby "+str(p)])
	await fixture(wp(0,.3,-53.5),rear)
	var court:Array=[]
	for p in [Vector3(-4.8,0,14),Vector3(-4.8,0,9),Vector3(3.6,0,9),Vector3(3.6,0,15),Vector3(-4.8,0,15),Vector3(-4.8,0,9),Vector3(0,0,5),Vector3(0,0,-6),Vector3(0,0,5),Vector3(-4.8,0,9),Vector3(-4.8,0,16)]:court.append([wp(p.x,p.y,p.z),"lower court public threshold "+str(p)])
	await fixture(wp(-4.8,.3,19),court)
	# One affected court/link circuit, not the entire student building or campus.
	await fixture(wp(-9,.3,40),[[wp(-9,0,38),"first stair foot"],[wp(-9,4.4,17),"court stair ascent"],[wp(-3,4.4,18),"court aisle"],[wp(0,4.4,18),"court centre"],[wp(0,4.4,35.5),"front bridge approach"],[wp(0,4.4,48),"upper promenade joint"]])
	await capture("student-lower-v151-rear",wp(-33,5,-64),wp(-15,2.5,-46))
	await capture("student-lower-v151-lobby",wp(-9.6,1.75,-36),wp(-9.6,1.75,-49))
	await capture("student-lower-v151-court",wp(0,2.0,20),wp(-1,3.5,11))
	await capture("student-lower-v151-threshold",wp(-4.8,1.75,9),wp(-4.8,1.75,17))
	await capture("student-lower-v151-section",wp(2,8,43),wp(-1,10,-13))
	FileAccess.open("res://tests/artifacts/student_lower_entries_v151.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":3,"scope":"Fitted rear 1F doors, two court doorways and first stair/upper promenade only; street datum and complete rooms remain unverified"},"\t"))
	print("STUDENT_LOWER_V151 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
