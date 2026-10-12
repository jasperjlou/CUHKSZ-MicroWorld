extends "res://tests/StudentRegisteredV153.gd"
var st:=Transform3D.IDENTITY
func sp(x:float,y:float,z:float)->Vector3:return st*Vector3(x,y,z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	st=world.builder.buildings["sports_complex"].global_transform
	var checks:Array=[]
	var route:Array=[]
	for p:Vector3 in [Vector3(32,2.24,-928),Vector3(30,2.24,-926.5),Vector3(24,2.24,-926.5),Vector3(22,2.24,-928),sp(31,0,19),sp(31,0,11),sp(31,0,8),sp(31,0,11),sp(31,0,19),sp(-58,0,19),sp(-68,0,19),sp(-68,0,-24),sp(-55,0,-24),sp(-10,0,-24),sp(10,0,-24),sp(10,0,19),Vector3(22,2.24,-928),Vector3(24,2.24,-926.5),Vector3(30,2.24,-926.5),sp(42,0,19)]:route.append([p,"remaining bypass circuit "+str(p)])
	await fixture(sp(59,0.3,19),route)
	await capture("sports-v174-final-field",sp(0,7,-122),sp(0,4.4,-4))
	await capture("sports-v174-final-underpass",sp(10,1.8,18),sp(10,2,-20))
	await capture("sports-v174-final-screens",sp(53,2.1,-24),sp(27,2,-7))
	await capture("sports-v174-final-closed-end",sp(-68,3,-29),sp(-45,3,-13))
	FileAccess.open("res://tests/artifacts/sports_undercroft_v174_tail.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Inter-hall ground routes, central field access, service doors and bypasses around the restored lower end; not unseen University Hall rear interior or current survey."},"\t"))
	print("SPORTS_V174_TAIL ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
