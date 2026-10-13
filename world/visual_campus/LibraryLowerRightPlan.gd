extends RefCounted
## Ground right tip: registered legacy outline, curved public map boundary,119 connections.
## The floor is independently fitted; this does not establish the upper-floor registration.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryUpperLevels.gd")
const Pods=preload("res://world/visual_campus/LibraryStudyPods.gd")
const Room=preload("res://world/visual_campus/LibraryInteractive119.gd")

static func outer_edge()->PackedVector2Array:
	var q=Room.outline()
	var map=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
	var tip:Vector3=map.point3(1785,620);var front:Vector3=map.point3(1608,798)
	return PackedVector2Array([q[2],Vector2(30,-14.2),Vector2(33.8,-10.2),Vector2(38.2,-6.1),Vector2(43,-2.5),Vector2(tip.x,tip.z),Vector2(front.x,front.z),Vector2(33.3,8.0),Vector2(28.3,6.1),Vector2(23.32,4.0)])

static func outline()->PackedVector2Array:
	var room=Room.outline()
	var p=PackedVector2Array([room[0],room[1]])
	p.append_array(outer_edge())
	p.append_array(PackedVector2Array([Vector2(30.1,8.8),Vector2(20.35,18.3),Vector2(10,8.6),Vector2(room[0].x,3.18)]))
	return p

static func contains(x:float,z:float)->bool:
	return Geometry2D.is_point_in_polygon(Vector2(x,z),outline())

static func public_light_fits(x:float,z:float)->bool:
	# V146: include the whole panel plus wall clearance, not just its centre.
	# The former light at (17,0) protruded into116 as a bright triangular fragment.
	var footprint:=PackedVector2Array([Vector2(x-.725,z-.575),Vector2(x+.725,z-.575),Vector2(x+.725,z+.575),Vector2(x-.725,z+.575)])
	if not Geometry2D.clip_polygons(footprint,outline()).is_empty():return false
	for excluded:PackedVector2Array in [Room.outline(),preload("res://world/visual_campus/LibraryLowerRightWing.gd").stacks_outline()]:
		if not Geometry2D.intersect_polygons(footprint,excluded).is_empty():return false
	return true

static func build(parent:Node3D)->void:
	var n=K.holder(parent,"LibraryGroundRightRegisteredBoundary")
	var floor=outline()
	P.sheet(n,floor,.014,"b9b4a4",12,true)
	P.sheet(n,floor,.107,"c4c5c1",46)
	# The closed116 store has its own sloping roof below the exterior main stair.
	var upper=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
	var ceiling_parts:Array[PackedVector2Array]=upper.subtract([floor],Room.outline())
	ceiling_parts=upper.subtract(ceiling_parts,preload("res://world/visual_campus/LibraryLowerRightWing.gd").stacks_outline())
	for part in ceiling_parts:P.sheet(n,part,4.09,"b5b7ac",62,false,false,86,58,true)
	# V116 whole2F outline now supplies this floor. Do not refill the exterior stair with an old cap.
	var edge=outer_edge()
	for i in edge.size()-1:
		if i==5:continue # Common full-height pavilion end owns this glazing.
		var a=edge[i];var c=edge[i+1];var count=maxi(1,int(ceil(a.distance_to(c)/1.65)))
		for j in count:
			var p=a.lerp(c,float(j)/count);var q=a.lerp(c,float(j+1)/count)
			Pods.strip(n,p,q,2.13,3.86,.085,"9eafa4",19,true)
			K.box(n,Vector3(p.x,2.16,p.y),Vector3(.065,4.25,.065),"a8b7aa",false,11)
		for y in [.17,4.10]:Pods.strip(n,a,c,y,.20,.21,"babfb2",22,true)
	# Public lights stop at the registered perimeter and do not cut through119 or116.
	for x in range(17,46,4):
		for z in range(-12,9,4):
			if public_light_fits(x,z):
				preload("res://world/visual_campus/LibraryLowerCeiling.gd").light(n,Vector3(x,4.02,z))
	K.finish(n)
