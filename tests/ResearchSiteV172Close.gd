extends "res://tests/ResearchSiteV172.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	rt=world.builder.buildings["research"].global_transform
	var checks:Array=[]
	for p:Vector2 in [Vector2(130,-781),Vector2(143,-799.5),Vector2(156,-818),Vector2(156.1,-832)]:
		var h:float=world.builder.height(p.x,p.y)
		probe(Vector3(p.x,h+.25,p.y),Vector3(p.x,h-.25,p.y),true,"service connector floor "+str(p),checks)
	var route:Array=[]
	for p:Vector3 in [Vector3(156,2.24,-818),Vector3(143,3.44,-799.5),Vector3(130,4.64,-781),Vector3(143,3.44,-799.5),Vector3(156,2.24,-818),rp(50,0,-54),rp(0,0,-54),rp(0,0,-44),rp(0,0,-37)]:route.append([p,"corrected service connector return "+str(p)])
	await fixture(rp(50,.3,-54),route)
	await capture("research-v172-site-final",Vector3(-123,164,-982),Vector3(102,13,-889))
	await capture("research-v172-tower-final",Vector3(-8,21,-762),Vector3(106,32,-912))
	await capture("research-v172-front-final",rp(83,34,105),rp(3,24,8))
	await capture("research-v172-rear-final",rp(-59,10,-66),rp(8,14,-35))
	FileAccess.open("res://tests/artifacts/research_site_v172_close.json",FileAccess.WRITE).store_string(JSON.stringify({"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Only changed service connector grade and return to rear doorway; no vehicle acceptance."},"\t"))
	print("RESEARCH_V172_CLOSE ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
