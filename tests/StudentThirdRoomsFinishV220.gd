extends "res://tests/StudentThirdRoomsV220.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(18)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for y in [1.6,6.,10.4]:
		for u in [540,570,660]:probe(pp(u,40,y),pp(u,5,y),true,"hidden facade collider remains "+str([u,y]),checks)
	await capture("student-third-v220-final-cell",third(565,128,10.5),third(565,45,10.3))
	await capture("student-third-v220-final-inner",third(687,180,10.5),third(440,120,10.5))
	await capture("student-third-v220-final-outside",pp(560,-80,8),pp(560,35,9.6))
	FileAccess.open("res://tests/artifacts/student_third_rooms_v220_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"checks":checks,"failures":failures,"captures":captures,"physical_geometry_changed":false,"scope":"Hidden envelope physics retained; visual window reveals/low-level glazing only"},"\t"))
	print("STUDENT_THIRD_V220_FINISH ",JSON.stringify({"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
