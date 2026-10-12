extends "res://tests/OldLibraryCoresV165.gd"
const Atrium=preload("res://world/visual_campus/OldLibraryAtrium.gd")
func ap(x:float,z:float,y:float)->Vector3:return op(x,z-17.16,y)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for y:float in [4.6,8.3,12.,15.7]:probe(ap(-10,0,y+.3),ap(-10,0,y-.3),false,"central void through floor/roof "+str(y),checks)
	for y:float in [4.72,8.42,12.12]:
		probe(ap(-1,0,y+.2),ap(-1,0,y-.2),true,"stair bridge deck "+str(y),checks)
		for z:float in [-1.,1.]:probe(ap(-10,z*3.,y+.6),ap(-10,z*4.,y+.6),true,"lightwell guard "+str([y,z]),checks)
	probe(ap(-6,0,15.5),ap(-6,0,18.0),false,"roof box no longer blocks skylight",checks)
	var route:Array=[[op(0,-10,.12),"main door"],[op(-3.4,-10,.12),"approach atrium"],[ap(-3.4,0,.12),"deck approach"],[ap(-1,0,.12),"central stair bridge"]]
	for i in 3:
		var low:float=Atrium.LEVELS[i]+.12;var high:float=Atrium.LEVELS[i+1]+.12;var mid:float=(low+high)/2
		for p in [Vector3(-1,low,-1.4),Vector3(0,low,-1.4),Vector3(7,mid,-1.4)]:route.append([ap(p.x,p.z,p.y),"central ascent "+str(i)+str(p)])
		for j in range(1,9):
			var p:=Atrium.turn_point(-PI/2+j*PI/8,1.4,mid);route.append([ap(p.x,p.z,p.y),"curved landing ascent "+str([i,j])])
		for p in [Vector3(0,high,1.4),Vector3(-1,high,1.4),Vector3(-1,high,3.8),Vector3(-1,high,5.2),Vector3(-1,high,3.8),Vector3(-1,high,0)]:route.append([ap(p.x,p.z,p.y),"upper gallery connection "+str(i)+str(p)])
	for p in [Vector2(-1,5.2),Vector2(-24,5.2),Vector2(-24,-5.2),Vector2(12,-5.2),Vector2(12,5.2),Vector2(-1,5.2),Vector2(-1,3.8),Vector2(-1,1.4)]:route.append([ap(p.x,p.y,12.12),"fourth floor lightwell circuit "+str(p)])
	for i in range(3,0,-1):
		var high:float=Atrium.LEVELS[i]+.12;var low:float=Atrium.LEVELS[i-1]+.12;var mid:float=(low+high)/2
		for p in [Vector3(0,high,1.4),Vector3(7,mid,1.4)]:route.append([ap(p.x,p.z,p.y),"central descent "+str(i)+str(p)])
		for j in range(1,9):
			var p:=Atrium.turn_point(PI/2-j*PI/8,1.4,mid);route.append([ap(p.x,p.z,p.y),"curved landing descent "+str([i,j])])
		for p in [Vector3(0,low,-1.4),Vector3(-1,low,-1.4),Vector3(-1,low,1.4)]:route.append([ap(p.x,p.z,p.y),"lower landing "+str(i)+str(p)])
	for p in [Vector2(-1,0),Vector2(-3.4,0),Vector2(-3.4,6.5),Vector2(0,6.5),Vector2(0,10)]:route.append([ap(p.x,p.y,.12),"return to main door "+str(p)])
	await fixture(op(0,-7,.35),route)
	await capture("old-library-v167-curve",ap(15,1.5,1.85),ap(6,0,6.2))
	await capture("old-library-v167-lightwell",ap(-13,0,1.85),ap(-6,0,15.8))
	await capture("old-library-v167-gallery",ap(-18,5.2,10.1),ap(3,0,9))
	await capture("old-library-v167-roof",ap(-1,19,29),ap(-6,0,15.8))
	FileAccess.open("res://tests/artifacts/old_library_atrium_v167.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Fitted central curved stairs and lightwell,2025photo carpet; not complete metric plan or2026renovated layout."},"\t"))
	print("OLD_LIBRARY_ATRIUM_V167 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
