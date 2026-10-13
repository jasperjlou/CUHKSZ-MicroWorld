extends "res://tests/StudentRegisteredV153.gd"
const Frame219=preload("res://world/visual_campus/StudentGroundFrame.gd")
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(18)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for q in Frame219.supports():probe(pp(q[0]-12,q[1],1.6),pp(q[0]+12,q[1],1.6),true,"historic1F support "+str(q),checks)
	for uv in [[465,338],[559,460],[465,190]]:probe(pp(uv[0],uv[1],.2),pp(uv[0],uv[1],2.2),false,"adjacent aisle headroom "+str(uv),checks)
	# One loop through ground hall, the traced column aisles and the rear lobby; no resets between legs.
	var route:Array=[]
	for q in [[450,500],[470,500],[550,500],[660,500],[660,380],[660,290],[550,290],[470,290],[470,200],[540,200],[560,180],[560,110],[650,110],[660,290],[660,380],[660,500],[750,480],[800,447.5],[890,447.5],[945,447.5],[890,447.5],[800,447.5],[750,480],[660,500],[550,500],[450,500],[400,500]]:route.append([pp(q[0],q[1],.075),"ground column aisle "+str(q)])
	await fixture(pp(400,500,.2),route)
	if DisplayServer.get_name()!="headless":
		await capture("student-ground-v219-middle",pp(665,490,1.75),pp(430,335,4.6))
		await capture("student-ground-v219-north",pp(665,110,1.75),pp(435,190,2.5))
		await capture("student-ground-v219-entry",pp(385,498,1.75),pp(650,480,3.5))
		await capture("student-ground-v219-rear",pp(870,375,1.75),pp(770,320,2.5))
	FileAccess.open("res://tests/artifacts/student_ground_frame_v219.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"failures":failures,"captures":captures,"fixtures":1,"scope":"Historic1F missing supports and local ground routes; no whole-building or current-fitout acceptance"},"\t"))
	print("STUDENT_GROUND_V219 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
