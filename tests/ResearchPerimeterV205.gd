extends "res://tests/ResearchSiteV172.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=62
	rt=world.builder.buildings["research"].global_transform
	var points:Array=[]
	for r:Dictionary in world.data.routes:
		if r.id=="research_service":
			for i in range(11,r.points.size()):
				var p:=Vector3(r.points[i][0],0,r.points[i][2]);p.y=world.builder.height(p.x,p.z);points.append(p)
	var forward:Array=[];var reverse:Array=[]
	for i in range(1,points.size()):forward.append([points[i],"rear return to existing front street "+str(i)])
	await fixture(points[0]+Vector3.UP*.3,forward)
	for i in range(points.size()-2,-1,-1):reverse.append([points[i],"front street return to rear lane "+str(i)])
	await fixture(points.back()+Vector3.UP*.3,reverse)
	var foot:Array=[]
	for p:Vector2 in [Vector2(-52,-43),Vector2(-56,-39),Vector2(-56,15),Vector2(-56,45),Vector2(-53,55),Vector2(-45,63),Vector2(-31,69),Vector2(-12,70),Vector2(0,70)]:
		var q:Vector3=rp(p.x,0,p.y);q.y=world.builder.height(q.x,q.z)+.065;foot.append([q,"inside footway "+str(p)])
	await fixture(rp(-46,.35,-43),foot)
	var checks:Array=[]
	probe(rp(0,1.7,-41),rp(0,1.7,-35),false,"rear doorway unaffected",checks)
	probe(rp(48,1.7,44),rp(48,1.7,47),false,"opposite stair foot unaffected",checks)
	probe(rp(-56,.5,15),rp(-56,-.5,15),true,"new walk support",checks)
	await capture("research-perimeter-v205-rear",rp(25,2,-54),rp(-58,2.2,-49))
	await capture("research-perimeter-v205-return",rp(-81,17,62),rp(-56,0,21))
	await capture("research-perimeter-v205-front",rp(-33,7,87),rp(-2,6,44))
	await capture("research-perimeter-v205-side",rp(-60,1.9,40),rp(-65,3,-42))
	var counts:Dictionary=world.get_node("ResearchPerimeterV205").get_meta("counts")
	FileAccess.open("res://tests/artifacts/research_perimeter_v205.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"plants":counts,"scope":"Fitted research rear-to-front service return on foot and inner sidewalk; no vehicle or surveyed geometry acceptance; other campus regions not rerun."},"\t"))
	print("RESEARCH_PERIMETER_V205 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures,"plants":counts}));quit(0 if failures.is_empty() else 1)
