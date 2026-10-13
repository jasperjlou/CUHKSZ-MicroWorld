extends "res://tests/StudentRegisteredV153.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(18)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for uv in [[470,290],[550,350],[650,380],[650,490]]:
		probe(pp(uv[0],uv[1],4.6),pp(uv[0],uv[1],3.5),true,"restored intermediate floor "+str(uv),checks)
		probe(pp(uv[0],uv[1],.2),pp(uv[0],uv[1],2.2),false,"ground headroom "+str(uv),checks)
		probe(pp(uv[0],uv[1],4.5),pp(uv[0],uv[1],6.5),false,"second floor headroom "+str(uv),checks)
	if DisplayServer.get_name()=="headless":
		var route:Array=[]
		for q in [[470,290],[550,290],[650,290],[650,350],[650,385],[650,490],[560,490],[470,490],[470,470],[580,470],[650,470],[650,385],[650,290],[550,290],[470,290],[470,220]]:route.append([pp(q[0],q[1],4.4),"restored2F aisle "+str(q)])
		await fixture(pp(470,220,4.6),route)
	else:
		await capture("student-ground-v219-final-middle",pp(665,490,1.75),pp(430,335,2.2))
		await capture("student-ground-v219-final-north",pp(665,110,1.75),pp(435,190,2.5))
		await capture("student-ground-v219-final-second",pp(670,370,6.1),pp(450,310,6.1))
		await capture("student-ground-v219-final-court",pp(320,355,6.1),pp(650,360,11))
	var suffix:String="physical" if DisplayServer.get_name()=="headless" else "visual"
	FileAccess.open("res://tests/artifacts/student_ground_frame_v219_finish_"+suffix+".json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"failures":failures,"captures":captures,"fixtures":1 if suffix=="physical" else 0,"scope":"Restored2F slab/headroom; unchanged ground-foot routes retained from initial run"},"\t"))
	print("STUDENT_GROUND_V219_FINISH ",suffix," ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
