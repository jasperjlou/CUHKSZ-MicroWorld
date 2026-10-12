extends "res://tests/StudentRegisteredV153.gd"
var tt:=Transform3D.IDENTITY
func tp(x:float,y:float,z:float)->Vector3:return tt*Vector3(x,y,z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	tt=world.builder.buildings["track"].global_transform
	var checks:Array=[]
	for x in [-50,0,50]:probe(tp(x,1.7,59),tp(x,1.7,47),false,"open field frontage x"+str(x),checks)
	probe(tp(-20,1.7,-51),tp(-20,1.7,-56),true,"outer straight fence collision",checks)
	probe(tp(-20,2.8,-51),tp(-20,2.8,-56),true,"raised mesh guard collision",checks)
	probe(tp(14,1.7,-51),tp(14,1.7,-58),false,"retained provisional outer service bay",checks)
	probe(tp(-92,1.7,0),tp(-101,1.7,0),false,"retained provisional end bay",checks)
	var route:Array=[]
	for p:Vector3 in [tp(-50,0,60),tp(-50,0,45),tp(-50,0,60),tp(50,0,60),tp(50,0,45),tp(70,0,0),tp(92,0,0),tp(101,0,0),tp(92,0,0),tp(89.96,0,-19.79),tp(78.75,0,-36.56),tp(61.98,0,-47.77),tp(42.195,0,-51.7),tp(14,0,-51.7),tp(14,0,-59),tp(14,0,-51.7),tp(-42.195,0,-51.7),tp(-61.98,0,-47.77),tp(-78.75,0,-36.56),tp(-89.96,0,-19.79),tp(-92,0,0),tp(-101,0,0),tp(-92,0,0),tp(-70,0,0),tp(-50,0,45),tp(-50,0,60),tp(14,0,60),tp(14,0,70),tp(14,0,83)]:route.append([p,"field edge circuit "+str(p)])
	await fixture(tp(14,.3,60),route)
	await capture("track-v175-overall",tp(126,96,-147),tp(0,0,4))
	await capture("track-v175-frontage",tp(52,2.0,61),tp(-42,1.8,56))
	await capture("track-v175-red-end",tp(-83,2.0,-16),tp(-40,1.5,12))
	await capture("track-v175-mesh",tp(-21,1.9,-48),tp(-16,1.7,-57))
	FileAccess.open("res://tests/artifacts/track_edges_v175.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Changed track frontage, infield ends and outer service circulation; no full-campus or surveyed grade claim."},"\t"))
	print("TRACK_V175 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
