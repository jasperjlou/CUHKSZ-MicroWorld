extends "res://tests/StudentRegisteredV153.gd"
var st:=Transform3D.IDENTITY
func sp(x:float,y:float,z:float)->Vector3:return st*Vector3(x,y,z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	st=world.builder.buildings["sports_complex"].global_transform
	var checks:Array=[]
	probe(sp(-53,1.7,-18),sp(-53,1.7,-14),true,"far lower white enclosure replaces fictitious arcade",checks)
	probe(sp(10,1.7,19),sp(10,1.7,-25),false,"inter-hall court to field gate stays open",checks)
	probe(sp(0,2.4,-14),sp(0,2.4,14),false,"central undercroft headroom",checks)
	probe(sp(43,3,-9),sp(43,3,-7),true,"blue perforated wedge retains guard collision",checks)
	probe(sp(19,2,-9),sp(19,2,-7),true,"yellow wedge guard",checks)
	probe(sp(-19,2,-9),sp(-19,2,-7),true,"purple wedge guard",checks)
	probe(sp(-53,1.7,23),sp(-53,1.7,17),false,"campus-side bypass outside white wing",checks)
	probe(sp(42.8,1.7,0),sp(39.5,1.7,0),false,"retained service side entrance",checks)
	probe(sp(59,1.7,14.5),sp(48,1.7,14.5),false,"retained end stair approach",checks)
	var route:Array=[]
	for p:Vector3 in [Vector3(30,2.24,-926.5),Vector3(24,2.24,-926.5),Vector3(22,2.24,-928),sp(10,0,19),sp(10,0,12),sp(10,0,-3),sp(10,0,-25),Vector3(0,2.24,-979),Vector3(0,2.24,-986),Vector3(0,2.24,-979),sp(10,0,-25),sp(58,0,-24),sp(68,0,-24),sp(68,0,0),sp(59,0,0),sp(59,0,14.5),sp(48,0,14.5),sp(59,0,14.5),sp(59,0,0),sp(45,0,0),sp(39,0,0),sp(45,0,0),sp(59,0,0),sp(59,0,19),sp(31,0,19),sp(31,0,11),sp(31,0,8),sp(31,0,11),sp(31,0,23),sp(-58,0,23),sp(-68,0,23),sp(-68,0,-24),sp(-55,0,-24),sp(-10,0,-24),sp(10,0,-24),sp(10,0,19),sp(42,0,19)]:route.append([p,"hall court undercroft and field circuit "+str(p)])
	await fixture(Vector3(32,2.54,-928),route)
	await capture("sports-v174-final-field",sp(0,7,-122),sp(0,4.4,-4))
	await capture("sports-v174-final-underpass",sp(10,1.8,18),sp(10,2,-20))
	await capture("sports-v174-final-screens",sp(53,2.1,-24),sp(27,2,-7))
	await capture("sports-v174-final-closed-end",sp(-68,3,-29),sp(-45,3,-13))
	FileAccess.open("res://tests/artifacts/sports_undercroft_v174_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Inter-hall ground routes, central field access, service doors and bypasses around the restored lower end; not unseen University Hall rear interior or current survey."},"\t"))
	print("SPORTS_V174_FINISH ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
