extends RefCounted
## V250: official70040608 front lower tiles show herringbone beside grey rectangular stone.
## Surface extents/modules fitted; existing road/ground collision is unchanged.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
static func rect(r:Rect2)->PackedVector2Array:
	return PackedVector2Array([r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)])
static func build(root:Node3D,builder)->void:
	var n:=K.holder(root,"ShawStreetPavingV250")
	var route:Array=[]
	for r:Dictionary in builder.data.routes:
		if r.id=="shaw_corner_link":route=r.points
	var normals:Array[Vector2]=[]
	for i in route.size():
		var p:=Vector2(route[i][0],route[i][2]);var a:=Vector2(route[maxi(0,i-1)][0],route[maxi(0,i-1)][2]);var b:=Vector2(route[mini(route.size()-1,i+1)][0],route[mini(route.size()-1,i+1)][2])
		var incoming:Vector2=(p-a).normalized() if i>0 else (b-p).normalized()
		var outgoing:Vector2=(b-p).normalized() if i<route.size()-1 else incoming
		var n1:=Vector2(-incoming.y,incoming.x);var n2:=Vector2(-outgoing.y,outgoing.x)
		var m:Vector2=(n1+n2).normalized();normals.append(m/maxf(.62,m.dot(n2)))
	# Clip every finish around the real model steps, retained stone bed and tactile pad.
	var cuts:Array[PackedVector2Array]=[
		rect(Rect2(72.23,-578.12,8.64,4.30)),rect(Rect2(82.28,-578.12,4.04,4.30)),
		rect(Rect2(54.2,-579.5,3.6,1.0))]
	var bed:=PackedVector2Array()
	for i in 48:
		var a:float=TAU*i/48;bed.append(Vector2(64.5+cos(a)*5.53,-576.5+sin(a)*1.88))
	cuts.append(bed)
	var clip_bounds:=rect(Rect2(55,-595,44.3,20.96))
	var triangles:int=0
	for band:Array in [[4.82,5.02,"626561",82],[5.02,7.02,"918a83",85],[7.02,7.24,"626561",82],[7.24,18.0,"a0a39f",86]]:
		var vertices:=PackedVector3Array()
		for i in range(route.size()-1):
			var a:=Vector2(route[i][0],route[i][2]);var b:=Vector2(route[i+1][0],route[i+1][2])
			var steps:int=maxi(1,ceili(a.distance_to(b)/.7))
			for j in steps:
				var t:float=float(j)/steps;var u:float=float(j+1)/steps
				var pa:=a.lerp(b,t);var pb:=a.lerp(b,u);var na:Vector2=normals[i].lerp(normals[i+1],t);var nb:Vector2=normals[i].lerp(normals[i+1],u)
				var quad:=PackedVector2Array([pa+na*band[0],pb+nb*band[0],pb+nb*band[1],pa+na*band[1]])
				var pieces:Array[PackedVector2Array]=Geometry2D.intersect_polygons(quad,clip_bounds)
				for cut:PackedVector2Array in cuts:
					var next:Array[PackedVector2Array]=[]
					for poly:PackedVector2Array in pieces:next.append_array(Geometry2D.clip_polygons(poly,cut))
					pieces=next
				for poly:PackedVector2Array in pieces:
					var ids:=Geometry2D.triangulate_polygon(poly)
					for k in range(0,ids.size(),3):
						var ps:Array[Vector3]=[]
						for m in 3:
							var p:Vector2=poly[ids[k+m]];ps.append(Vector3(p.x,builder.height(p.x,p.y)+.146,p.y))
						if (ps[1]-ps[0]).cross(ps[2]-ps[0]).y>0:ps.reverse()
						vertices.append_array(PackedVector3Array(ps));triangles+=1
		if not vertices.is_empty():
			var mesh:=K.surface(n,vertices,band[2],band[3]);mesh.name="StreetFinish"+str(band[3]);mesh.set_meta("surface_kind",band[3])
	n.set_meta("triangles",triangles);K.finish(n)
