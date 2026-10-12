extends "res://tests/ResearchPodiumV169.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(rp(32,1.7,40),rp(32,1.7,36),false,"new lower portal open",checks)
	probe(rp(26,1.7,40),rp(26,1.7,36),true,"portal side glazing retains collision",checks)
	probe(rp(47,7.2,28),rp(43,7.2,28),false,"middle side door open",checks)
	probe(rp(47,2,28),rp(43,2,28),true,"wall below side door retained",checks)
	probe(rp(47,12.8,4),rp(43,12.8,4),false,"upper rail exit open",checks)
	probe(rp(43,6.1,43),rp(43,6.1,45),true,"projecting terrace stone guard",checks)
	probe(rp(48,7.6,20),rp(48,10,20),false,"side flight headroom",checks)
	var route:Array=[]
	for p in [Vector3(32,0,50),Vector3(32,0,40),Vector3(32,0,35),Vector3(32,0,24),Vector3(16,0,24),Vector3(0,0,24),Vector3(0,0,41),Vector3(16,0,41),Vector3(16,0,53),Vector3(48,0,53),Vector3(48,0,44),Vector3(48,5.5,28),Vector3(43,5.5,28),Vector3(43,5.5,41),Vector3(23,5.5,41),Vector3(43,5.5,41),Vector3(43,5.5,28),Vector3(48,5.5,28),Vector3(48,11.5,4),Vector3(42,11.5,4),Vector3(42,11.5,-35.5),Vector3(0,11.5,-35.5),Vector3(42,11.5,-35.5),Vector3(42,11.5,4),Vector3(48,11.5,4),Vector3(48,5.5,28),Vector3(48,0,44),Vector3(48,0,53)]:route.append([rp(p.x,p.y,p.z),"side portal stair terrace circuit "+str(p)])
	await fixture(rp(32,.3,53),route)
	await capture("research-v171-arrival",rp(72,8,68),rp(35,7,35))
	await capture("research-v171-stairs",rp(64,10,47),rp(47,9,18))
	await capture("research-v171-terrace",rp(22,7.3,41),rp(47,9,27))
	await capture("research-v171-upper",rp(53,15,-4),rp(43,9,30))
	FileAccess.open("res://tests/artifacts/research_side_v171.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Fitted Research side stairs lower portal projecting terrace and upper perimeter; not surveyed hill road connection"},"\t"))
	print("RESEARCH_V171 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
