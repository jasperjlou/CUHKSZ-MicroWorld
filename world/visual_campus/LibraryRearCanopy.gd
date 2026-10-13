extends RefCounted
## Official rear-road panorama 116440797: white covered waiting area on brick paving.
## Local bench, roof dimensions and road offset are fitted; no measured elevation.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const B:=preload("res://world/visual_campus/RearRoadBank.gd")
const X:=130.4
const Z:=-242.0

static func level()->float:
	return B.road_height(Z)

static func fitted_height(x:float,z:float,base:float)->float:
	var w:float=smoothstep(X-5.4,X-3.6,x)*(1.0-smoothstep(X+3.6,X+5.4,x))
	w*=smoothstep(Z-7.4,Z-5.4,z)*(1.0-smoothstep(Z+5.4,Z+7.4,z))
	return lerpf(base,level(),w)

static func build(root:Node3D,builder)->void:
	var n:=K.holder(root,"LibraryRearCoveredWaitingV194",Vector3(X,level(),Z))
	n.set_meta("source_scene",116440797)
	n.set_meta("fitted_bench","Moved2.1m toward retained roadside to avoid unsupported deep rear overhang;flat core with graded margins")
	K.box(n,Vector3(0,-.3,0),Vector3(6.8,.6,10.4),"8b918a",false,15)
	K.box(n,Vector3(0,.021,0),Vector3(6.8,.032,10.4),"978779",false,7)
	for side in [-1,1]:
		K.box(n,Vector3(side*3.32,.038,0),Vector3(.16,.018,10.4),"b1b5ac",false,26)
		K.box(n,Vector3(0,.038,side*5.12),Vector3(6.8,.018,.16),"b1b5ac",false,26)
	for x in [-2.9,2.9]:
		for z in [-4.4,0.0,4.4]:
			K.box(n,Vector3(x,1.67,z),Vector3(.17,3.3,.17),"d0d3c8",true,22)
		K.box(n,Vector3(x,3.31,0),Vector3(.23,.22,10.5),"c3cac3",false,22)
	# Full shallow roof with clipped corners; its underside is continuous.
	var ring:Array[Vector2]=[Vector2(-3.4,-5.5),Vector2(3.4,-5.5),Vector2(3.65,-5.25),Vector2(3.65,5.25),Vector2(3.4,5.5),Vector2(-3.4,5.5),Vector2(-3.65,5.25),Vector2(-3.65,-5.25)]
	var mesh:=PackedVector3Array()
	for i in ring.size():
		var p:=Vector3(ring[i].x,3.45,ring[i].y);var q:=Vector3(ring[(i+1)%ring.size()].x,3.45,ring[(i+1)%ring.size()].y)
		mesh.append_array(PackedVector3Array([Vector3(0,3.45,0),p,q]))
		mesh.append_array(PackedVector3Array([Vector3(0,3.29,0),q-Vector3.UP*.16,p-Vector3.UP*.16]))
		mesh.append_array(K.quad(p,q,q-Vector3.UP*.16,p-Vector3.UP*.16))
	var roof:=K.surface(n,mesh,"d7d9cd",22,true)
	var material:=StandardMaterial3D.new();material.albedo_color=Color("d7d9cd");material.roughness=.85;material.cull_mode=BaseMaterial3D.CULL_DISABLED;roof.material_override=material
	K.finish(n)
	# The lateral apron follows the same graded terrain, with no collider lip.
	var apron:=K.holder(root,"RearCanopyRoadApronV194")
	var vertices:=PackedVector3Array()
	for x in range(133,135):
		var pts:Array[Vector3]=[Vector3(x,0,Z+1),Vector3(x+1,0,Z+1),Vector3(x+1,0,Z+3.4),Vector3(x,0,Z+3.4)]
		for i in 4:pts[i].y=builder.height(pts[i].x,pts[i].z)+.045
		vertices.append_array(K.quad(pts[0],pts[1],pts[2],pts[3]))
	K.surface(apron,vertices,"978779",7)
