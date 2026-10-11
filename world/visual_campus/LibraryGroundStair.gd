extends RefCounted
## Official Ground panorama25181872 shows low timber tiers AND a narrow stair.
## Distinct from the high2F-3F public stair. Metre registration remains fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const ORIGIN := Vector3(.4,0,-1)
const YAW := PI*.75
const RUN := 10.5

static func point(p:Vector3) -> Vector3:
	return ORIGIN+Basis(Vector3.UP,YAW)*p

static func in_opening(x:float,z:float,margin:float=0) -> bool:
	var p:=Basis(Vector3.UP,-YAW)*(Vector3(x,0,z)-ORIGIN)
	return absf(p.x)<1.55+margin and p.z>4.7-margin and p.z<RUN+.3+margin

static func cut_opening(polygon:PackedVector2Array) -> Array[PackedVector2Array]:
	# Partition the outside into four disjoint strips. clip_polygons can return an
	# enclosed hole as a second polygon; triangulating that polygon would refill it.
	var local_poly:=PackedVector2Array()
	for vertex in polygon:
		var p:=Basis(Vector3.UP,-YAW)*(Vector3(vertex.x,0,vertex.y)-ORIGIN)
		local_poly.append(Vector2(p.x,p.z))
	var result:Array[PackedVector2Array]=[]
	for rect:Rect2 in [Rect2(-500,-500,498.45,1000),Rect2(1.55,-500,498.45,1000),Rect2(-1.55,-500,3.1,504.7),Rect2(-1.55,RUN+.3,3.1,500-RUN-.3)]:
		var quad:=PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)])
		for clipped:PackedVector2Array in Geometry2D.intersect_polygons(local_poly,quad):
			var restored:=PackedVector2Array()
			for vertex in clipped:
				var p:=point(Vector3(vertex.x,0,vertex.y));restored.append(Vector2(p.x,p.z))
			result.append(restored)
	return result

static func build(parent:Node3D) -> void:
	var b:=K.holder(parent,"LibraryGroundTimberTierAndStair",ORIGIN);b.rotation.y=YAW
	preload("res://world/visual_campus/LibraryEntryLevels.gd").flight(b,RUN,4.4,2.4)
	K.box(b,Vector3(0,4.28,RUN+.45),Vector3(2.95,.24,.9),"b8b9ad",true,12)
	# Six deep sitting tiers stop below the low ceiling; they do not masquerade as a2F floor.
	for i in 6:
		var h:float=(i+1)*.28
		K.box(b,Vector3(5.0,h/2,(i+.5)*.85),Vector3(7.0,h,.85),"bc9561",true,43)
		K.box(b,Vector3(5.0,h+.012,(i+.5)*.85),Vector3(7.0,.024,.83),"c2a271",false,43)
		for x in [3.0,5.7]:
			if (i+int(x))%2==0:K.box(b,Vector3(x,h+.045,(i+.5)*.85),Vector3(1.05,.07,.55),["b77a54","566477","bdab57"][i%3],false,22)
	# Return at the short edge, visible in the panorama near the triangular tables.
	for i in 3:K.box(b,Vector3(7.7,(i+1)*.14,-.32+i*.38),Vector3(1.6,(i+1)*.28,.76),"bc9561",true,43)
	K.box(b,Vector3(5.0,2.8,5.18),Vector3(7.0,2.35,.16),"b7905e",true,43)
	K.box(b,Vector3(5.0,2.98,5.065),Vector3(5.4,1.52,.045),"dddcd0",false,22)
	K.box(b,Vector3(5.0,3.91,2.5),Vector3(7.1,.10,5.5),"b6ac83",false,16)
	# Solid low-end underside keeps the structural enclosure independent of the study rooms.
	for side in [-1,1]:
		var x:float=side*1.2
		K.surface(b,PackedVector3Array([Vector3(x,0,0),Vector3(x,2.2,5.25),Vector3(x,0,5.25),Vector3(x,0,0),Vector3(x,0,5.25),Vector3(x,2.2,5.25)]),"c4b797",22,true)
	K.box(b,Vector3(0,1.025,5.25),Vector3(2.4,2.05,.1),"c4b797",true,22)
	# Upper floor guards follow the actual new opening; neither mouth is obstructed.
	for side in [-1,1]:
		K.box(b,Vector3(side*1.55,4.96,(4.7+RUN+.3)/2),Vector3(.08,1.08,RUN+.3-4.7),"87968b",true,19)
		K.box(b,Vector3(side*1.55,5.53,(4.7+RUN+.3)/2),Vector3(.09,.06,RUN+.3-4.7),"8f9a8f",false,11)
	K.box(b,Vector3(0,4.96,4.7),Vector3(3.1,1.08,.08),"87968b",true,19)
	K.finish(b)
