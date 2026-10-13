extends "res://tests/StudentThirdRoomsV220.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(18)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for q in [[550,580],[650,630],[760,670]]:
		probe(third(q[0],q[1],13),third(q[0],q[1],11.8),false,"double height no4F slab "+str(q),checks)
		probe(third(q[0],q[1],9.3),third(q[0],q[1],8.4),true,"hall floor support "+str(q),checks)
	for q in [[465,610],[650,525]]:probe(third(q[0],q[1],12.9),third(q[0],q[1],12.0),true,"gallery supported "+str(q),checks)
	probe(third(650,533,14),third(650,565,14),true,"upper glass protects void north",checks)
	probe(third(480,630,14),third(520,630,14),true,"upper glass protects void west",checks)
	probe(third(749,490,10.2),third(749,520,10.2),false,"hall double door",checks)
	probe(third(410,536,10.2),third(445,536,10.2),false,"hall west entry",checks)
	probe(third(620,490,10.2),third(620,520,10.2),true,"hall wood partition",checks)
	probe(third(780,646,10.2),third(810,646,10.2),true,"end glazing closed",checks)
	if DisplayServer.get_name()=="headless":
		var route:Array=[]
		for q in [[749,485],[749,520],[730,550],[650,550],[500,550],[445,536],[410,536],[445,536],[470,610],[530,655],[720,655],[760,620],[760,550],[749,520],[749,485]]:route.append([third(q[0],q[1]),"hall door and perimeter "+str(q)])
		await fixture(third(720,485,9.05),route)
		var upper:Array=[]
		for q in [[460,580],[460,660],[460,580],[460,525],[600,525],[750,525],[600,525],[460,525]]:upper.append([third(q[0],q[1],12.4),"4F gallery "+str(q)])
		await fixture(third(460,525,12.65),upper)
	else:
		await capture("student-hall-v221-entry",third(749,480,10.5),third(625,645,11.7))
		await capture("student-hall-v221-floor",third(750,660,10.5),third(450,530,12.0))
		await capture("student-hall-v221-gallery",third(600,521,14.1),third(640,650,11.5))
		await capture("student-hall-v221-west",third(446,630,10.5),third(765,602,12.3))
	var suffix:String="physical" if DisplayServer.get_name()=="headless" else "visual"
	FileAccess.open("res://tests/artifacts/student_multi_hall_v221_"+suffix+".json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"failures":failures,"captures":captures,"fixtures":2 if suffix=="physical" else 0,"scope":"301 lower hall and fitted4F glazing/void only; upper lightwell unregistered"},"\t"))
	print("STUDENT_HALL_V221 ",suffix," ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
