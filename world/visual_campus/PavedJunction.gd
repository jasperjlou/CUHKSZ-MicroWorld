extends RefCounted
## Clip the lower road finish below an already-authored paver ribbon.
## Reconstruct its exact plan offsets; collision and ground heights are untouched.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
static func clip(road:MeshInstance3D,points:Array,width:float)->void:
	var offsets:Array[Vector2]=[]
	for i in points.size():
		var a:=Vector2(points[maxi(0,i-1)][0],points[maxi(0,i-1)][2])
		var p:=Vector2(points[i][0],points[i][2]);var b:=Vector2(points[mini(points.size()-1,i+1)][0],points[mini(points.size()-1,i+1)][2])
		var incoming:Vector2=(p-a).normalized() if i>0 else (b-p).normalized()
		var outgoing:Vector2=(b-p).normalized() if i<points.size()-1 else incoming
		var n1:=Vector2(incoming.y,-incoming.x);var n2:=Vector2(outgoing.y,-outgoing.x)
		var miter:Vector2=(n1+n2).normalized()
		offsets.append(miter*width/2/minf(1.0,maxf(.62,miter.dot(n2))))
	var cuts:Array[PackedVector2Array]=[]
	for i in range(points.size()-1):
		var a:=Vector2(points[i][0],points[i][2]);var b:=Vector2(points[i+1][0],points[i+1][2])
		cuts.append(PackedVector2Array([a-offsets[i],a+offsets[i],b+offsets[i+1],b-offsets[i+1]]))
	var arrays:Array=road.mesh.surface_get_arrays(0);var vertices:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
	var indices:PackedInt32Array=arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX]!=null else PackedInt32Array()
	var source:=PackedVector3Array()
	if indices.is_empty():source=vertices
	else:
		for index in indices:source.append(vertices[index])
	var out:=PackedVector3Array();var affected:int=0
	for i in range(0,source.size(),3):
		var a:Vector3=source[i];var b:Vector3=source[i+1];var c:Vector3=source[i+2]
		if maxf(a.z,maxf(b.z,c.z))< -515 or minf(a.z,minf(b.z,c.z))> -492:
			out.append_array(PackedVector3Array([a,b,c]));continue
		var pieces:Array[PackedVector2Array]=[PackedVector2Array([Vector2(a.x,a.z),Vector2(b.x,b.z),Vector2(c.x,c.z)])]
		for cut:PackedVector2Array in cuts:
			var next:Array[PackedVector2Array]=[]
			for polygon:PackedVector2Array in pieces:next.append_array(Geometry2D.clip_polygons(polygon,cut))
			pieces=next
		var normal:Vector3=(b-a).cross(c-a)
		for polygon:PackedVector2Array in pieces:
			var ids:PackedInt32Array=Geometry2D.triangulate_polygon(polygon)
			for j in range(0,ids.size(),3):
				var ps:Array[Vector3]=[]
				for k in 3:
					var q:Vector2=polygon[ids[j+k]]
					var y:float=a.y-(normal.x*(q.x-a.x)+normal.z*(q.y-a.z))/normal.y
					ps.append(Vector3(q.x,y,q.y))
				if (ps[1]-ps[0]).cross(ps[2]-ps[0]).y>0:ps.reverse()
				out.append_array(PackedVector3Array(ps))
		affected+=1
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for v:Vector3 in out:st.add_vertex(v)
	st.generate_normals();road.mesh=st.commit();road.set_meta("paver_junction_clipped_triangles",affected)
