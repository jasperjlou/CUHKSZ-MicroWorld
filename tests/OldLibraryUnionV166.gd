extends "res://tests/OldLibraryCoresV165.gd"
func tcp(x:float,z:float,y:float)->Vector3:return op(35+x,-13+z,y)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for y in [4.6,8.3,12.]:
		probe(tcp(0,0,y+.25),tcp(0,0,y-.2),false,"third stair slab void "+str(y),checks)
		probe(tcp(-4,0,y+.3),tcp(-4,0,y),true,"third stair landing "+str(y),checks)
		for x in [-27.,27.]:
			probe(op(x,-11,y+1.6),op(x,-8,y+1.6),false,"rear-return join "+str([x,y]),checks)
			probe(op(x,3,y+1.6),op(x,7,y+1.6),false,"return-front join "+str([x,y]),checks)
	probe(op(20,-13,1.7),op(29,-13,1.7),false,"internal courtyard glazing removed",checks)
	probe(op(27,-11,1.7),op(27,-8,1.7),false,"internal rear entry glazing removed",checks)
	probe(op(40,-20,4.9),op(44,-20,4.9),true,"outer rear end still enclosed",checks)
	probe(op(31,-20,17),op(31,-17,17),true,"upper teaching setback retained",checks)
	var route:Array=[[op(0,-16,.12),"main entrance"],[op(28,-16,.12),"opposite common aisle"],[tcp(-6,0,.12),"third core approach"]]
	for i in 3:
		var low:float=Old.LEVELS[i]+.12;var high:float=Old.LEVELS[i+1]+.12;var mid:float=(low+high)/2
		for p in [Vector3(-4,low,0),Vector3(-3,low,-.85),Vector3(3,mid,-.85),Vector3(3.85,mid,-.85),Vector3(3.85,mid,.85),Vector3(3,mid,.85),Vector3(-3,high,.85),Vector3(-4,high,0),Vector3(-6,high,0)]:route.append([tcp(p.x,p.z,p.y),"third ascent "+str(i)+str(p)])
	for p in [Vector2(27,-13),Vector2(27,0),Vector2(27,12),Vector2(32,12),Vector2(27,12),Vector2(27,0),Vector2(27,-16),Vector2(0,-16),Vector2(-27,-16),Vector2(-27,0),Vector2(-27,12),Vector2(-32,12),Vector2(-27,12),Vector2(-27,0),Vector2(-27,-16),Vector2(-28,-21)]:route.append([op(p.x,p.y,12.12),"fourth floor joined wings "+str(p)])
	var cz:float=Old.CZ[0];route.append([ocp(-6,0,12.12,cz),"paired core return"])
	for i in range(3,0,-1):
		var high:float=Old.LEVELS[i]+.12;var low:float=Old.LEVELS[i-1]+.12;var mid:float=(low+high)/2
		for p in [Vector3(-4,high,0),Vector3(-3,high,.85),Vector3(3,mid,.85),Vector3(3.85,mid,.85),Vector3(3.85,mid,-.85),Vector3(3,mid,-.85),Vector3(-3,low,-.85),Vector3(-4,low,0),Vector3(-6,low,0)]:route.append([ocp(p.x,p.z,p.y,cz),"paired descent "+str(i)+str(p)])
	for p in [Vector2(-28,-16),Vector2(0,-16),Vector2(27,-16),Vector2(27,3),Vector2(18,3),Vector2(0,3),Vector2(0,-7)]:route.append([op(p.x,p.y,.12),"ground return via wing door "+str(p)])
	await fixture(op(0,-7,.35),route)
	await capture("old-library-v166-third",tcp(-5.9,-.7,1.8),tcp(2,0,3.))
	await capture("old-library-v166-joint",op(27,-16,13.85),op(27,12,13.85))
	await capture("old-library-v166-opposite",op(-27,-16,13.85),op(-27,12,13.85))
	await capture("old-library-v166-envelope",op(3,21,27),op(24,-12,13))
	FileAccess.open("res://tests/artifacts/old_library_union_v166.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Fitted third core and joined wings only; retained massing not surveyed; central atrium and current renovated interior remain open."},"\t"))
	print("OLD_LIBRARY_UNION_V166 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
