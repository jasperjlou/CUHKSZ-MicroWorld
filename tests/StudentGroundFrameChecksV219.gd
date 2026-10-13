extends "res://tests/StudentRegisteredV153.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(18)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false)
	var checks:Array=[]
	for uv in [[470,290],[550,350],[650,380],[650,490]]:
		probe(pp(uv[0],uv[1],4.6),pp(uv[0],uv[1],3.5),true,"downward support ray "+str(uv),checks)
		probe(pp(uv[0],uv[1],.2),pp(uv[0],uv[1],2.2),false,"ground headroom "+str(uv),checks)
		probe(pp(uv[0],uv[1],4.5),pp(uv[0],uv[1],6.5),false,"second floor headroom "+str(uv),checks)
	# Old465/154 probe intersected dining furniture, not a circulation aisle.
	probe(pp(465,190,.2),pp(465,190,2.2),false,"north dining aisle clear",checks)
	FileAccess.open("res://tests/artifacts/student_ground_frame_v219_checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"geometry_changed":false,"scope":"Correct downward ray for one-sided floor; no repeated physical routes"},"\t"))
	print("STUDENT_GROUND_V219_CHECKS ",JSON.stringify({"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
