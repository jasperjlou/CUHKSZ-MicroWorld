extends "res://tests/StudentRegisteredV153.gd"
const Rooms220=preload("res://world/visual_campus/StudentThirdRooms.gd")
func third(u:float,v:float,y:float=8.8)->Vector3:return Rooms220.world(u,v,y)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(18)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for u in [469,564,662]:probe(third(u,188,10.2),third(u,215,10.2),false,"north public door "+str(u),checks)
	for v in [287,405]:probe(third(780,v,10.2),third(813,v,10.2),false,"side room doorway "+str(v),checks)
	probe(third(803,330,10.2),third(803,355,10.2),true,"side room partition",checks)
	probe(third(479,80,10.2),third(528,80,10.2),true,"small room partition",checks)
	if DisplayServer.get_name()=="headless":
		var route:Array=[]
		for q in [[469,187],[469,133],[442,133],[442,115],[442,78],[442,115],[484,115],[484,78],[484,115],[526,115],[526,78],[526,115],[566,115],[566,78],[566,115],[608,115],[608,78],[608,115],[648,115],[648,78],[648,115],[690,115],[690,78],[690,133],[662,187],[662,220],[564,220],[564,180],[564,220],[750,220],[750,287],[780,287],[816,287],[865,287],[816,287],[780,287],[750,287],[750,405],[780,405],[816,405],[865,405],[816,405],[780,405],[750,405],[750,220],[469,220]]:route.append([third(q[0],q[1]),"3F partition aisle "+str(q)])
		await fixture(third(469,220,9),route)
	else:
		await capture("student-third-v220-gallery",third(443,220,10.5),third(687,205,10.5))
		await capture("student-third-v220-inner",third(687,180,10.5),third(440,120,10.5))
		await capture("student-third-v220-cell",third(565,128,10.5),third(565,45,10.3))
		await capture("student-third-v220-side",third(750,425,10.5),third(815,280,10.5))
	var suffix:String="physical" if DisplayServer.get_name()=="headless" else "visual"
	FileAccess.open("res://tests/artifacts/student_third_rooms_v220_"+suffix+".json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"failures":failures,"captures":captures,"fixtures":1 if suffix=="physical" else 0,"scope":"Historic3F subdivisions and local routes only; no current room identity claim"},"\t"))
	print("STUDENT_THIRD_V220 ",suffix," ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
