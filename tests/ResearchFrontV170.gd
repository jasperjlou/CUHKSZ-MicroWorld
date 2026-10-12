extends "res://tests/ResearchPodiumV169.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(rp(0,13,37),rp(0,13,10),false,"public front-to-garden axis retained",checks)
	probe(rp(28,25,43),rp(28,25,37),true,"lower glass arm",checks)
	probe(rp(39,47,43),rp(39,47,37),true,"higher glass arm",checks)
	probe(rp(28,47,43),rp(28,47,37),false,"sky above lower arm",checks)
	probe(rp(33,30,43),rp(33,30,33),false,"open deep notch between arms",checks)
	probe(rp(33,15,43),rp(33,15,33),true,"glazed bottom link",checks)
	probe(rp(22.24,21,37),rp(22.24,21,33),true,"curved facade collision",checks)
	probe(rp(21,20,35),rp(21,19,35),true,"curved slab actual footprint",checks)
	var route:Array=[]
	for p in [Vector3(0,5.5,49),Vector3(0,11.5,37),Vector3(0,11.5,28),Vector3(0,11.5,17),Vector3(0,11.5,10),Vector3(-8,11.5,13.8),Vector3(0,11.5,13.8),Vector3(0,11.5,28),Vector3(0,11.5,37),Vector3(0,5.5,49),Vector3(0,0,65),Vector3(9,0,65),Vector3(9,0,41),Vector3(0,0,41),Vector3(0,0,35),Vector3(0,0,-37)]:route.append([rp(p.x,p.y,p.z),"revised front shell circuit "+str(p)])
	await fixture(rp(0,.3,65),route)
	await capture("research-v170-front",rp(-3,27,105),rp(2,31,28))
	await capture("research-v170-corner",rp(80,25,99),rp(25,32,27))
	await capture("research-v170-shades",rp(-7,20,42),rp(9,31,33))
	await capture("research-v170-garden",rp(-14,17,-3),rp(19,35,26))
	await capture("research-v170-massing",rp(90,84,99),rp(0,24,0))
	FileAccess.open("res://tests/artifacts/research_front_v170.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Photo-led front curved wing and stepped glazed end; fitted scale and levels, not whole campus registration"},"\t"))
	print("RESEARCH_V170 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
