extends "res://tests/StudentRegisteredV153.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(18)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for v in [351,379,438]:probe(pp(200,v,1.6),pp(240,v,1.6),false,"1F exterior doorway "+str(v),checks)
	probe(pp(200,290,1.6),pp(240,290,1.6),true,"1F yellow pier",checks)
	probe(pp(400,365,1.6),pp(450,365,1.6),false,"false ground courtyard wall removed",checks)
	probe(pp(400,220,1.6),pp(400,260,1.6),false,"north ground hall continuous",checks)
	probe(pp(660,272,1.6),pp(720,272,1.6),true,"service frontage enclosure",checks)
	probe(pp(650,365,3.4),pp(650,365,1.2),false,"main aisle headroom",checks)
	if DisplayServer.get_name()=="headless":
		var route:Array=[]
		for q in [[208,438],[240,438],[270,438],[270,365],[400,365],[445,365],[650,365],[650,445],[750,447.5],[890,447.5],[945,447.5],[890,447.5],[750,447.5],[650,445],[650,480],[450,480],[400,480],[400,365],[400,200],[540,200],[650,200],[650,365],[270,365],[270,379],[200,379],[190,351],[240,351],[270,351]]:route.append([pp(q[0],q[1],.075),"canteen1F "+str(q)])
		await fixture(pp(180,438,.2),route)
		await fixture(pp(190,528,.2),[[pp(220,528,.075),"retained fitted stair mouth"],[pp(285,528,4.4),"first court ascent"],[pp(330,528,4.4),"court landing"],[pp(350,470,4.4),"upper circulation"],[pp(350,365,4.4),"upper court retained"]])
	else:
		await capture("student-canteen-v223-room",pp(390,370,1.75),pp(665,305,2.1))
		await capture("student-canteen-v223-service",pp(650,430,1.75),pp(694,282,1.65))
		await capture("student-canteen-v223-front",pp(180,400,1.75),pp(245,330,2.1))
		await capture("student-canteen-v223-north",pp(400,200,1.75),pp(480,390,2.1))
	var suffix:String="physical" if DisplayServer.get_name()=="headless" else "visual"
	FileAccess.open("res://tests/artifacts/student_canteen_v223_"+suffix+".json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"failures":failures,"captures":captures,"fixtures":2 if suffix=="physical" else 0,"scope":"1F public dining and ground envelope; old first stair mouth retained as fitted; no2F fitout acceptance"},"\t"))
	print("STUDENT_CANTEEN_V223 ",suffix," ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
