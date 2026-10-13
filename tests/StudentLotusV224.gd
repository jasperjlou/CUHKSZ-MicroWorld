extends "res://tests/StudentRegisteredV153.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(18)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(pp(400,300,6.0),pp(450,300,6.0),false,"2F court entry",checks)
	probe(pp(680,306,6.0),pp(740,306,6.0),false,"retained rear-side portal",checks)
	probe(pp(660,376,6.0),pp(720,376,6.0),true,"2F service glazing",checks)
	probe(pp(550,323,5.25),pp(580,323,5.25),true,"banquette back",checks)
	for u in [508,610]:
		for v in [235,338]:probe(pp(u-12,v,6.0),pp(u+12,v,6.0),true,"continued2F support "+str([u,v]),checks)
	probe(pp(650,315,4.5),pp(650,315,7.0),false,"main dining aisle headroom",checks)
	if DisplayServer.get_name()=="headless":
		var route:Array=[]
		for q in [[450,300],[480,300],[480,315],[525,315],[525,215],[650,215],[650,306],[740,306],[800,306],[740,306],[650,306],[650,425],[650,480],[580,480],[580,400],[650,400],[650,215],[450,215],[450,110],[650,110],[650,215],[525,215],[525,315],[480,315],[450,315],[450,300],[400,300],[400,440]]:route.append([pp(q[0],q[1],4.4),"lotus2F "+str(q)])
		route.append([pp(580,440,8.8),"middle stair upper landing"])
		route.append([pp(620,440,8.8),"3F upper courtyard"])
		route.append([pp(580,440,8.8),"upper landing return"])
		route.append([pp(400,440,4.4),"middle stair descent"])
		route.append([pp(400,300,4.4),"2F court entry return"])
		await fixture(pp(400,300,4.6),route)
	else:
		await capture("student-lotus-v224-room",pp(450,315,6.1),pp(605,340,6.5))
		await capture("student-lotus-v224-service",pp(650,300,6.1),pp(688,390,6.1))
		await capture("student-lotus-v224-booth",pp(525,250,6.1),pp(565,330,5.5))
		await capture("student-lotus-v224-court",pp(370,325,6.1),pp(525,305,6.3))
	var suffix:String="physical" if DisplayServer.get_name()=="headless" else "visual"
	FileAccess.open("res://tests/artifacts/student_lotus_v224_"+suffix+".json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"failures":failures,"captures":captures,"fixtures":1 if suffix=="physical" else 0,"scope":"Fitted2F dining,retained doors,court stair; no whole-building geometry/current-date acceptance"},"\t"))
	print("STUDENT_LOTUS_V224 ",suffix," ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
