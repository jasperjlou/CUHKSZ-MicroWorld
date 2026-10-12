extends "res://tests/ResearchSiteV172.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	rt=world.builder.buildings["research"].global_transform
	var checks:Array=[]
	probe(rp(19,13.2,32.2),rp(20,13.2,32.6),false,"curved undercroft replaces previous outer glass obstruction",checks)
	probe(rp(19,13.2,32),rp(19,13.2,30),true,"recessed glass still encloses interior",checks)
	probe(rp(21.3,13,34.2),rp(21.3,13,32.5),true,"round support has physical collision",checks)
	probe(rp(-39,12.3,37.5),rp(-39,12.3,38.5),false,"retired rail no longer divides forecourt",checks)
	probe(rp(-39,12.3,43),rp(-39,12.3,45),true,"new outer terrace guard",checks)
	probe(rp(-39,11.7,42),rp(-39,11.2,42),true,"extended terrace has solid floor",checks)
	probe(rp(-32,11.8,37.8),rp(-32,11.8,39.2),true,"tree bed stone wall collision",checks)
	probe(rp(19,7.2,41),rp(23,7.2,41),false,"middle terrace remains clear below new upper apron",checks)
	probe(rp(19,14,32.3),rp(19,15.2,32.3),false,"undercroft headroom",checks)
	var route:Array=[]
	for p:Vector3 in [Vector3(0,5.5,49),Vector3(0,11.5,37),Vector3(0,11.5,35),Vector3(-39,11.5,35),Vector3(-40,11.5,43),Vector3(-8,11.5,43),Vector3(-8,11.5,35),Vector3(8,11.5,35),Vector3(23,11.5,35),Vector3(23,11.5,37.5),Vector3(20,11.5,32.6),Vector3(19,11.5,32.2),Vector3(19,11.5,35),Vector3(0,11.5,35),Vector3(0,11.5,3),Vector3(0,11.5,35),Vector3(0,11.5,37),Vector3(0,5.5,49),Vector3(0,0,65)]:route.append([rp(p.x,p.y,p.z),"upper terrace continuous circuit "+str(p)])
	await fixture(rp(0,.3,65),route)
	await capture("research-v173-terrace",rp(-39,15.5,47),rp(-6,14,35))
	await capture("research-v173-undercroft",rp(17,13.3,37),rp(23,14.2,33))
	await capture("research-v173-glass",rp(-18,13.4,37),rp(-7,14.5,33))
	await capture("research-v173-overall",rp(-66,30,87),rp(0,16,24))
	FileAccess.open("res://tests/artifacts/research_terrace_v173.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Source-led upper forecourt and recessed curved ground glass; retained fitted levels, not absolute hill/tower registration."},"\t"))
	print("RESEARCH_V173 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
