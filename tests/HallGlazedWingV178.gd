extends "res://tests/StudentRegisteredV153.gd"
func hp178(x:float,y:float,z:float)->Vector3:return world.builder.buildings["sports_hall"].to_global(Vector3(x,y,z))
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(hp178(18,2.4,10.25),hp178(22,2.4,10.25),false,"reception side passage",checks)
	probe(hp178(18,2.4,6.5),hp178(22,2.4,6.5),true,"side wall beside passage",checks)
	probe(hp178(18,5,10.25),hp178(22,5,10.25),true,"passage head wall",checks)
	probe(hp178(32,1.6,16),hp178(32,.4,16),true,"side wing floor",checks)
	probe(hp178(30,7,15),hp178(30,7.7,15),true,"ribbed ceiling slab",checks)
	probe(hp178(43,2,15),hp178(46,2,15),true,"lower glazing boundary",checks)
	probe(hp178(43,6,15),hp178(46,6,15),true,"clerestory boundary",checks)
	probe(hp178(43,10,10),hp178(46,10,10),true,"retained upper Hall panels",checks)
	var route:Array=[]
	for p:Vector3 in [Vector3(10,0,37),Vector3(10,.84,33),Vector3(10,.84,24),Vector3(10,.84,17),Vector3(10,.84,12),Vector3(17,.84,10.25),Vector3(22,.84,10.25),Vector3(30,.84,10.25),Vector3(34,.84,18),Vector3(42,.84,16),Vector3(42,.84,23),Vector3(34,.84,23),Vector3(27,.84,15),Vector3(22,.84,10.25),Vector3(17,.84,10.25),Vector3(10,.84,12),Vector3(10,.84,24),Vector3(10,.84,33),Vector3(10,0,37),Vector3(10,0,40)]:route.append([hp178(p.x,p.y,p.z),"public wing circuit "+str(p)])
	await fixture(hp178(10,.3,40),route)
	await fixture(hp178(48,.3,33),[[hp178(48,0,24),"outer covered aisle"],[hp178(48,0,10),"glazed side exterior"],[hp178(48,0,0),"side wall join"],[hp178(48,0,-24),"retained side perimeter"]])
	root.disable_3d=false;await frames(15)
	await capture("hall-v178-exterior",hp178(68,8,39),hp178(31,4,17))
	await capture("hall-v178-waiting",hp178(25,2.6,8),hp178(43,3.4,20))
	await capture("hall-v178-passage",hp178(27,2.6,12),hp178(13,3,10.25))
	await capture("hall-v178-window",hp178(40,2.6,17),hp178(45,4,12))
	FileAccess.open("res://tests/artifacts/hall_glazed_wing_v178.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":2,"scope":"Hollow public waiting wing, reception side passage, main entry and outside aisle only. Exact wing/site registration and entire Hall interior remain incomplete."},"\t"))
	print("HALL_WING_V178 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
