extends "res://tests/StudentRegisteredV153.gd"
const Old=preload("res://world/visual_campus/OldLibraryCores.gd")
func op(x:float,z:float,y:float=0.)->Vector3:return Vector3(-37.2+z,2.24+y,-733-x)
func ocp(x:float,z:float,y:float,cz:float)->Vector3:return op(Old.CX-x,-17.16+cz-z,y)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for cz:float in Old.CZ:
		for y in [4.6,8.3,12.]:
			probe(ocp(0,0,y+.25,cz),ocp(0,0,y-.20,cz),false,"real stair void "+str([cz,y]),checks)
			probe(ocp(-4,0,y+.3,cz),ocp(-4,0,y,cz),true,"stair landing "+str([cz,y]),checks)
		probe(ocp(-5.5,0,1.7,cz),ocp(-4,0,1.7,cz),false,"ground doorway "+str(cz),checks)
	probe(op(33,-20.96,1.6),op(36,-20.96,1.6),true,"lift remains closed",checks)
	var route:Array=[[op(0,-16,.12),"old library public entrance"],[op(-28,-16,.12),"common ground aisle"],[ocp(-6,0,.12,Old.CZ[0]),"first core approach"]]
	var cz:float=Old.CZ[0]
	for i in 3:
		var low:float=Old.LEVELS[i]+.12;var high:float=Old.LEVELS[i+1]+.12;var mid:float=(low+high)/2
		for p in [Vector3(-4,low,0),Vector3(-3,low,-.85),Vector3(3,mid,-.85),Vector3(3.85,mid,-.85),Vector3(3.85,mid,.85),Vector3(3,mid,.85),Vector3(-3,high,.85),Vector3(-4,high,0),Vector3(-6,high,0)]:route.append([ocp(p.x,p.z,p.y,cz),"main stair ascent "+str(i)+str(p)])
	route.append([op(-28,-17.16,12.12),"fourth floor shared aisle"])
	cz=Old.CZ[1];route.append([ocp(-6,0,12.12,cz),"second core upper approach"])
	for i in range(3,0,-1):
		var high:float=Old.LEVELS[i]+.12;var low:float=Old.LEVELS[i-1]+.12;var mid:float=(low+high)/2
		for p in [Vector3(-4,high,0),Vector3(-3,high,.85),Vector3(3,mid,.85),Vector3(3.85,mid,.85),Vector3(3.85,mid,-.85),Vector3(3,mid,-.85),Vector3(-3,low,-.85),Vector3(-4,low,0),Vector3(-6,low,0)]:route.append([ocp(p.x,p.z,p.y,cz),"second stair descent "+str(i)+str(p)])
	route.append([op(-28,-16,.12),"return common aisle"]);route.append([op(0,-16,.12),"return public hall"]);route.append([op(0,-7,.12),"return court"])
	await fixture(op(0,-7,.35),route)
	await capture("old-library-v165-core",ocp(-5.9,-.7,1.8,Old.CZ[0]),ocp(2,0,3.,Old.CZ[0]))
	await capture("old-library-v165-upper",ocp(-4,.25,13.8,Old.CZ[0]),ocp(2,0,9.,Old.CZ[0]))
	await capture("old-library-v165-paired",op(-26,-16,1.85),op(-35,-17.16,2.2))
	await capture("old-library-v165-lift",op(30,-19.9,1.9),op(35.8,-20.96,1.9))
	FileAccess.open("res://tests/artifacts/old_library_cores_v165.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Two fitted end cores and closed lift from old official guide topology; not whole-building metric registration,third core or current renovated fitout."},"\t"))
	print("OLD_LIBRARY_CORES_V165 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
