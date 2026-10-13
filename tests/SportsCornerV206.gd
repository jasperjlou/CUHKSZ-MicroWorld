extends "res://tests/ResearchSiteV172.gd"
func gp(x:float,z:float)->Vector3:return Vector3(x,world.builder.height(x,z)+.10,z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	rt=world.builder.buildings["research"].global_transform
	await fixture(gp(-131,-1087)+Vector3.UP*.3,[[gp(-127,-1087),"footway to corner apron"],[gp(-119,-1095),"across flat forecourt"],[gp(-109,-1102),"forecourt to tactile pad"],[gp(-106.5,-1108),"clear planter and cycle strip"],[gp(-106.5,-1129.8),"cross street"],[gp(-106.5,-1108),"return crossing"],[gp(-110,-1102),"return apron"],[gp(-124,-1097),"walk behind planters"],[gp(-131,-1094),"return old sidewalk"],[gp(-131,-1087),"old sidewalk continuation"]])
	var checks:Array=[]
	for pos:Vector2 in [Vector2(-127,-1088),Vector2(-120,-1094),Vector2(-110,-1101)]:
		var p:=gp(pos.x,pos.y);probe(p+Vector3.UP,p-Vector3.UP,true,"forecourt support "+str(pos),checks)
	await capture("sports-corner-v206-overall",Vector3(-166,12,-1132),Vector3(-119,0,-1091))
	await capture("sports-corner-v206-pedestrian",Vector3(-107,.05,-1131),Vector3(-119,-.1,-1090))
	await capture("sports-corner-v206-apron",Vector3(-131,.2,-1087),Vector3(-109,-.7,-1104))
	await capture("research-perimeter-v205-surface-complete",rp(-33,7,87),rp(-2,6,44))
	await capture("research-perimeter-v205-join-complete",Vector3(46,4,-905),Vector3(44,2.5,-886))
	FileAccess.open("res://tests/artifacts/sports_corner_v206.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"scope":"New fitted sports corner ground/crossing and retained sidewalk interfaces on foot; final Research visual finish. Not vehicle access or surveyed street registration."},"\t"))
	print("SPORTS_CORNER_V206 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
