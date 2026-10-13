extends "res://tests/StudentThirdRoomsV220.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(18)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(third(410,536,10.2),third(445,536,10.2),true,"unregistered drop has closed door",checks)
	probe(third(410,676,10.2),third(445,676,10.2),false,"lower west indoor door",checks)
	if DisplayServer.get_name()=="headless":
		var route:Array=[]
		for q in [[749,485],[749,520],[730,550],[650,550],[500,550],[445,536],[470,610],[445,676],[405,676],[380,660],[405,676],[445,676],[530,655],[720,655],[760,620],[760,550],[749,520],[749,485]]:route.append([third(q[0],q[1]),"final hall circulation "+str(q)])
		await fixture(third(720,485,9.05),route)
	else:
		await capture("student-hall-v221-final-floor",third(750,660,10.5),third(450,530,12.0))
		await capture("student-hall-v221-final-window",third(670,565,10.5),third(540,680,11.8))
		await capture("student-hall-v221-final-closed-door",third(490,562,10.5),third(425,536,10.3))
	var suffix:String="physical" if DisplayServer.get_name()=="headless" else "visual"
	FileAccess.open("res://tests/artifacts/student_multi_hall_v221_finish_"+suffix+".json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"failures":failures,"captures":captures,"fixtures":1 if suffix=="physical" else 0,"scope":"closed drop-facing door, supported southwest doorway, interior lining;4F gallery unchanged"},"\t"))
	print("STUDENT_HALL_FINISH_V221 ",suffix," ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
