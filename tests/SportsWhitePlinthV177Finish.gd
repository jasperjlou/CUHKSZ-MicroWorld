extends "res://tests/StudentRegisteredV153.gd"
const PL177=preload("res://world/visual_campus/SportsWhitePlinth.gd")
func sp177(x:float,y:float,z:float)->Vector3:return Vector3(-10+x,2.24+y,-947+z)
func low177(x:float,z:float)->Vector3:return sp177(x,-PL177.drop_at(x,z)+.07,z)
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(sp177(-73,-1,0),sp177(-69,-1,0),true,"lower retaining face",checks)
	probe(sp177(-68,1,0),sp177(-73,1,0),true,"terrace guard",checks)
	probe(sp177(-67,.8,0),sp177(-67,-.2,0),true,"terrace slab support",checks)
	probe(sp177(-60,1.5,-19),sp177(-67,1.5,-19),false,"field end terrace access",checks)
	probe(sp177(-67,1.5,18),sp177(-58,1.5,18),false,"campus end terrace access",checks)
	probe(sp177(-80,-1.6,0),sp177(-80,-3,0),true,"lower paving support",checks)
	probe(sp177(-64,7,2),sp177(-61,7,2),true,"opaque upper end band",checks)
	await fixture(sp177(-57,.3,-25),[[sp177(-59,.1,-19),"field approach"],[sp177(-67,.1,-19),"front return to terrace"],[sp177(-67,.1,0),"white wing outer terrace"],[sp177(-67,.1,18),"terrace campus end"],[sp177(-59,.1,18),"campus end return"],[sp177(-50,.1,22),"two hall forecourt"],[sp177(-20,.1,22),"existing forecourt connection"]])
	await fixture(low177(-80,24)+Vector3.UP*.3,[[low177(-82,10),"lower narrowed outer edge"],[low177(-82,-20),"lower narrowed court return"]])
	root.disable_3d=false;await frames(15)
	await capture("sports-v177-final-overall",sp177(-97,12,-47),sp177(-48,4.5,0))
	await capture("sports-v177-final-lower",sp177(-82,-.6,-9),sp177(-66,1.3,3))
	await capture("sports-v177-final-terrace",sp177(-68.5,1.85,-18),sp177(-66,2,16))
	await capture("sports-v177-final-band",sp177(-88,7.5,7),sp177(-62,7,0))
	FileAccess.open("res://tests/artifacts/sports_white_plinth_v177_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":2,"scope":"Photo-fitted white-end terrace, lower hardscape and local forecourt links. Lower grade2.4m not surveyed; terrain transition is provisional, no claim of as-built stairs or service-room interior."},"\t"))
	print("SPORTS_WHITE_V177_FINISH ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
