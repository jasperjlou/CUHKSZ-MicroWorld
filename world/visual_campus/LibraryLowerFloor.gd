extends RefCounted
## V241: June2025 public carpet photograph, with distinct timber study-room floors.
## Same authored footprints and collision slabs; finish fragments are non-overlapping.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const U=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
const Pods=preload("res://world/visual_campus/LibraryStudyPods.gd")
static func rect(x:float,z:float,w:float,d:float)->PackedVector2Array:
	return PackedVector2Array([Vector2(x,z),Vector2(x+w,z),Vector2(x+w,z+d),Vector2(x,z+d)])
static func room(poly:PackedVector2Array,centre:Vector2,yaw:float=0)->PackedVector2Array:
	var out:=PackedVector2Array()
	for p in poly:
		var q:=Basis(Vector3.UP,yaw)*Vector3(p.x,0,p.y);out.append(centre+Vector2(q.x,q.z))
	return out
static func timber_rooms()->Array[PackedVector2Array]:
	return [room(Pods.rounded_outline(8.9,7.95,.60),Vector2(-27.5,-1.8)),room(Pods.rounded_outline(5.5,6.2,.60),Vector2(-15.7,-1.8)),room(Pods.rounded_outline(3.2,3.2,.5),Vector2(-14.7,-10.4)),room(Pods.rounded_outline(3.2,3.2,.5),Vector2(-6.9,-.65),PI/2),room(Pods.rounded_outline(3.2,3.2,.5),Vector2(-6.9,6.3),PI*.75)]
static func regions()->Array[PackedVector2Array]:
	var rear:=PackedVector2Array([Vector2(-28,-8),Vector2(14.699643,-8)])
	var back:=preload("res://world/visual_campus/LibraryLowerRearPlan.gd").rear()
	for i in range(back.size()-1,-1,-1):rear.append(back[i])
	var exhibit:=PackedVector2Array()
	for q in [[370,702],[545,702],[545,765],[510,837],[370,837]]:
		var p:=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd").point1(q[0],q[1]);exhibit.append(Vector2(p.x,p.z))
	return [rect(-39,-16.8,24,27.8),rear,preload("res://world/visual_campus/LibraryLowerRightPlan.gd").outline(),rect(-15,-2.4,11.5,12.8),rect(3.5,-2.4,11.5,11.6),PackedVector2Array([Vector2(0,8),Vector2(8,8),Vector2(9.5,9),Vector2(8.5,13),Vector2(6,19),Vector2(0,19)]),exhibit]
static func pieces()->Array[PackedVector2Array]:
	var out:Array[PackedVector2Array]=[];var previous:Array[PackedVector2Array]=[]
	for region in regions():
		var parts:Array[PackedVector2Array]=Geometry2D.decompose_polygon_in_convex(region)
		for used in previous:parts=U.subtract(parts,used)
		for wood in timber_rooms():parts=U.subtract(parts,wood)
		out.append_array(parts);previous.append(region)
	return out
static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"LibraryLowerFloorV241")
	K.surface(n,U.floor_vertices(pieces(),.106),"c4c5c1",77)
	n.set_meta("scope","2025 public carpet; existing floor extents; .60m module fitted; no collision changes")
