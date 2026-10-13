extends "res://tests/StudentThirdRoomsV220.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(18)
	world.player.set_physics_process(false);var checks:Array=[]
	for q in [[510,59],[611,59],[510,160],[611,160]]:
		probe(third(q[0]-12,q[1],10.4),third(q[0]+12,q[1],10.4),true,"3F traced column "+str(q),checks)
		probe(third(q[0]-12,q[1],6),third(q[0]+12,q[1],6),q[1]==160,"2F source-supported continuation "+str(q),checks)
	FileAccess.open("res://tests/artifacts/student_third_columns_v220.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"scope":"Remove unsupported2Fextension ofv59pair;3F geometry and walked routes unchanged"},"\t"))
	print("STUDENT_THIRD_COLUMNS_V220 ",JSON.stringify({"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
