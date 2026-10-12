extends "res://tests/StudentRegisteredV153.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for z in [-376.,-365.,-354.]:
		var y:float=lerpf(2.24,-1.76,(z+380)/30.)
		probe(Vector3(17.2,y+.6,z),Vector3(18.5,y+.6,z),true,"ramp fall edge "+str(z),checks)
	probe(Vector3(15,3,-381),Vector3(15,3,-378),false,"upper ramp mouth clear",checks)
	probe(Vector3(15,-.3,-350),Vector3(19,-.3,-350),false,"lower landing headroom",checks)
	for z in [-366.8,-353.2]:probe(Vector3(47,-.3,z),Vector3(50,-.3,z),false,"arcade doorway "+str(z),checks)
	probe(Vector3(50.5,.5,-360),Vector3(50.5,2.4,-360),true,"arcade roof retained",checks)
	var route:Array=[]
	for p in [Vector3(15,-1.76,-350),Vector3(15,-1.76,-348),Vector3(26,-1.76,-348),Vector3(26,-1.76,-352),Vector3(38,-1.76,-352),Vector3(38,-1.76,-353.2),Vector3(50.5,-1.76,-353.2),Vector3(50.5,-1.76,-366.8),Vector3(38,-1.76,-366.8),Vector3(38,-1.76,-377),Vector3(28,-1.76,-377),Vector3(28,-1.76,-393),Vector3(28,-1.76,-377),Vector3(38,-1.76,-377),Vector3(38,-1.76,-352),Vector3(26,-1.76,-352),Vector3(26,-1.76,-348),Vector3(15,-1.76,-348),Vector3(15,-1.76,-350),Vector3(15,2.24,-383)]:route.append([p,"ramp lower arcade service link "+str(p)])
	await fixture(Vector3(15,2.54,-383),route)
	await capture("court-v164-ramp",Vector3(21,2.1,-356),Vector3(15,1.0,-369))
	await capture("court-v164-lower-room",Vector3(44.5,-.02,-362),Vector3(50.5,-.15,-367))
	await capture("court-v164-room-out",Vector3(51,-.05,-355.8),Vector3(44,-.1,-353.2))
	FileAccess.open("res://tests/artifacts/courtyard_lower_edges_v164.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Existing fitted lower-court ramp, arcade and service connection only; not identification or construction of the student's local basement."},"\t"))
	print("COURTYARD_LOWER_V164 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
