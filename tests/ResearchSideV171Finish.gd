extends "res://tests/ResearchSideV171.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(rp(42,12.3,4),rp(42,12.3,0),false,"upper join no longer blocked by cross guard",checks)
	probe(rp(48,12.3,4),rp(48,12.3,0),true,"guard retained at outer landing edge",checks)
	probe(rp(32,1.7,40),rp(32,1.7,44),false,"relocated canopy public approach clear",checks)
	probe(rp(32,3,46),rp(32,4.5,46),false,"vehicle road has no low canopy overhead",checks)
	var route:Array=[]
	for p in [Vector3(42,11.5,-35.5),Vector3(0,11.5,-35.5),Vector3(42,11.5,-35.5),Vector3(42,11.5,4),Vector3(48,11.5,4),Vector3(48,5.5,28),Vector3(48,0,44),Vector3(48,0,53),Vector3(32,0,53),Vector3(32,0,40),Vector3(32,0,35),Vector3(32,0,40),Vector3(32,0,53)]:route.append([rp(p.x,p.y,p.z),"upper continuation and canopy correction "+str(p)])
	await fixture(rp(42,11.8,4),route)
	await capture("research-v171-arrival-final",rp(72,8,68),rp(35,7,35))
	await capture("research-v171-terrace-final",rp(22,7.3,41),rp(47,9,27))
	await capture("research-v171-upper-final",rp(53,15,-4),rp(43,9,30))
	FileAccess.open("res://tests/artifacts/research_side_v171_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Resume at upper landing after guard opening;descend and verify canopy approach only"},"\t"))
	print("RESEARCH_V171_FINISH ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
