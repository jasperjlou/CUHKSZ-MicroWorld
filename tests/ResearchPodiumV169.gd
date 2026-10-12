extends "res://tests/StudentRegisteredV153.gd"
func rp(x:float,y:float,z:float)->Vector3:return Vector3(91-z,2.24+y,-845+x)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(rp(-14,1,0),rp(-14,18,0),false,"two podium slabs and garden skin opened",checks)
	probe(rp(-20,5.8,0),rp(-20,5.2,0),true,"middle gallery slab remains",checks)
	probe(rp(-20,11.8,0),rp(-20,11.2,0),true,"garden edge slab remains",checks)
	probe(rp(-19,6.2,0),rp(-17.8,6.2,0),true,"middle well guard retains collision",checks)
	probe(rp(-19,12.2,0),rp(-17.8,12.2,0),true,"garden well guard retains collision",checks)
	probe(rp(0,1.7,37),rp(0,1.7,-37),false,"original ground axial passage remains",checks)
	var route:Array=[]
	for p in [Vector3(0,0,35),Vector3(0,0,14),Vector3(-16,0,14),Vector3(-16,5.5,-9.5),Vector3(-12,5.5,-9.5),Vector3(-12,11.5,14),Vector3(0,11.5,14),Vector3(0,11.5,37),Vector3(0,5.5,49),Vector3(0,0,65),Vector3(9,0,65),Vector3(9,0,41),Vector3(0,0,41),Vector3(0,0,35),Vector3(0,0,14),Vector3(-16,0,14),Vector3(-16,5.5,-9.5),Vector3(-12,5.5,-9.5),Vector3(-12,11.5,14),Vector3(-12,5.5,-9.5),Vector3(-16,5.5,-9.5),Vector3(-16,0,14),Vector3(0,0,14),Vector3(0,0,-37)]:
		route.append([rp(p.x,p.y,p.z),"podium continuous circuit "+str(p)])
	await fixture(rp(0,.3,37),route)
	await capture("research-v169-lower",rp(-2,1.8,17),rp(-14,5.8,-5))
	await capture("research-v169-mid",rp(-18,7.2,-12),rp(-12,10,10))
	await capture("research-v169-garden",rp(-23,15,14),rp(-14,8,-1))
	await capture("research-v169-front",Vector3(18,14,-856),Vector3(89,23,-845))
	FileAccess.open("res://tests/artifacts/research_podium_v169.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Fitted lower podium stairs/lightwell, garden and existing exterior stair circuit; not tower bridge or whole-building registration"},"\t"))
	print("RESEARCH_V169 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
