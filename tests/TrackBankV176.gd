extends "res://tests/StudentRegisteredV153.gd"
const TS=preload("res://world/visual_campus/TrackOuterSite.gd")
func street_point176(i:int)->Vector3:
	var p:=TS.walk_point(i);p.y=world.builder.height(p.x,p.z)+.10;return p
func ground176(x:float,z:float)->Vector3:return Vector3(x,world.builder.height(x,z)+.10,z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for pair:Array in [[Vector3(0,3.94,-1081),Vector3(0,3.94,-1088),"former far bay closed"],[Vector3(-106,3.94,-1030),Vector3(-116,3.94,-1030),"former end bay closed"],[Vector3(77,3.94,-1030),Vector3(87,3.94,-1030),"other former end bay closed"]]:probe(pair[0],pair[1],true,pair[2],checks)
	probe(Vector3(0,3.94,-973),Vector3(0,3.94,-986),false,"open sports frontage",checks)
	for pos:Vector2 in [Vector2(0,-1082),Vector2(0,-1092),Vector2(0,-1103),Vector2(-135,-1030)]:
		var p:=ground176(pos.x,pos.y);probe(p+Vector3.UP,p-Vector3.UP,true,"surface support "+str(pos),checks)
	var route:Array=[]
	for i in 8:route.append([street_point176(i),"lower street inside sidewalk "+str(i)])
	for x in [-70,0,70,110]:route.append([ground176(x,-1103.2),"lower street long arm "+str(x)])
	await fixture(Vector3(-112,2.54,-958),route)
	await fixture(street_point176(2)+Vector3.UP*.3,[[street_point176(1),"street grade ascent"],[street_point176(0),"street grade upper tie"],[Vector3(-112,2.24,-958),"return campus road"]])
	await fixture(Vector3(0,2.54,-947),[[Vector3(0,2.24,-973),"undercroft to open frontage"],[Vector3(0,2.24,-988),"open track access"],[Vector3(-64,2.24,-985),"front side at field datum"],[Vector3(-64,2.24,-970),"return along white wing"],[Vector3(0,2.24,-970),"apron return"]])
	await capture("track-v176-overall",Vector3(112,98,-1177),Vector3(-14,1,-1026))
	await capture("track-v176-bank",Vector3(-12,.2,-1105),Vector3(-10,3.3,-1078))
	await capture("track-v176-corner",Vector3(-160,7,-1128),Vector3(-105,2,-1065))
	await capture("track-v176-tie",Vector3(-112,8,-964),Vector3(-142,0,-1015))
	FileAccess.open("res://tests/artifacts/track_bank_v176.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":3,"scope":"New outer street sidewalk descent/ascent, bank supports and closed former bays; field front retained. Relative terrain fit, not site survey or vehicle drive test."},"\t"))
	print("TRACK_BANK_V176 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
