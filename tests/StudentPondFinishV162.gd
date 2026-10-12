extends "res://tests/StudentPondUpperV162.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(fp(640,15,21),fp(640,27,21),true,"single-sheet screen boundary",checks)
	await capture("student-v162-notch-final",fp(350,-60,20),fp(350,100,20))
	await capture("student-v162-screen-final",fp(680,-100,19.5),fp(730,24,19.5))
	await capture("student-v162-perforations-final",fp(640,55,20.8),fp(640,20.5,20.8))
	FileAccess.open("res://tests/artifacts/student_pond_finish_v162.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"captures":captures,"failures":failures,"physical_legs":0,"scope":"Single-screen sheet reduces moire,decorative reveal offset hides old sills; unchanged galleries reuse earlier walking. Closeup is free inspection camera,not a walkable upper void."},"\t"))
	print("STUDENT_POND_FINISH_V162 ",JSON.stringify(checks));quit(0 if failures.is_empty() else 1)
