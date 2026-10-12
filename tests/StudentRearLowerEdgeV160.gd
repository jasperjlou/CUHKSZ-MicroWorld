extends "res://tests/StudentRearLowerCoreV160.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for v in [284.166667,460.833333]:probe(pp(918,v,13.8),pp(930,v,13.8),true,"fourth court former unsupported doorway "+str(v),checks)
	await capture("student-v160-court-edge-final",pp(750,460,14.1),pp(910,477,12.6))
	FileAccess.open("res://tests/artifacts/student_rear_lower_edge_v160.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"captures":captures,"failures":failures,"physical_legs":0,"scope":"Only outer fourth-court false doors closed; lower-core walking reused unchanged."},"\t"))
	print("STUDENT_REAR_LOWER_EDGE_V160 ",JSON.stringify(checks));quit(0 if failures.is_empty() else 1)
