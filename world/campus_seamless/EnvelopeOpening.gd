extends RefCounted
## Bounded polygon subtraction, performed only while baking the V5 exterior.
## V4 source/cache stays immutable. No collider bypass or controller changes.
static func split(poly: Array, axis: int, value: float, sign_dir: float) -> Array:
	var inside: Array=[];var outside: Array=[]
	for i in poly.size():
		var a: Vector3=poly[i];var b: Vector3=poly[(i+1)%poly.size()]
		var da: float=(a[axis]-value)*sign_dir;var db: float=(b[axis]-value)*sign_dir
		if da>=0:inside.append(a)
		else:outside.append(a)
		if (da>=0)!=(db>=0):
			var p:=a.lerp(b,da/(da-db));inside.append(p);outside.append(p)
	return [inside,outside]

static func subtract(poly: Array, cut: AABB) -> Array:
	var remaining: Array=poly;var result: Array=[]
	for axis in 3:
		for side in 2:
			if remaining.size()<3:return result
			var clipped:=split(remaining,axis,cut.position[axis] if side==0 else cut.end[axis],1.0 if side==0 else -1.0)
			remaining=clipped[0]
			if clipped[1].size()>=3:result.append(clipped[1])
	return result

static func apply(objects: Dictionary) -> void:
	var data: Array=JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/campus_interiors.json"))
	for d: Dictionary in data:
		var root: Node3D=objects[d.building_id]
		var cut:=AABB(Vector3(-d.width/2,-.1,d.center_local[2]-d.depth/2),Vector3(d.width,10.5,d.depth+5))
		root.set_meta("v5_opening",cut);root.set_meta("interior_confidence","INFERRED")
		var queue: Array[Node]=[root]
		while not queue.is_empty():
			var node: Node=queue.pop_back()
			for child: Node in node.get_children():queue.append(child)
			if node is CollisionShape3D and node.shape is BoxShape3D:
				var transform: Transform3D=root.global_transform.affine_inverse()*node.global_transform
				var box:=transform*AABB(-node.shape.size/2,node.shape.size)
				if not box.intersects(cut):continue
				# These architectural collision boxes are axis-aligned in building space.
				var bounds:=box.intersection(cut);var rem:=box;var pieces: Array[AABB]=[]
				for axis in 3:
					if rem.position[axis]<bounds.position[axis]:
						var part:=rem;part.size[axis]=bounds.position[axis]-rem.position[axis];pieces.append(part)
						rem.size[axis]-=part.size[axis];rem.position[axis]=bounds.position[axis]
					if rem.end[axis]>bounds.end[axis]:
						var part:=rem;part.position[axis]=bounds.end[axis];part.size[axis]=rem.end[axis]-bounds.end[axis];pieces.append(part);rem.size[axis]-=part.size[axis]
				node.disabled=true
				var body:=StaticBody3D.new();root.add_child(body)
				for part: AABB in pieces:
					if part.size.x<.001 or part.size.y<.001 or part.size.z<.001:continue
					var shape:=CollisionShape3D.new();var box_shape:=BoxShape3D.new();box_shape.size=part.size;shape.shape=box_shape;shape.position=part.get_center();body.add_child(shape)
			elif node is MeshInstance3D:
				var transform: Transform3D=root.global_transform.affine_inverse()*node.global_transform
				if not (transform*node.get_aabb()).intersects(cut):continue
				var mesh:=ArrayMesh.new()
				for surface in node.mesh.get_surface_count():
					var arrays: Array=node.mesh.surface_get_arrays(surface);var verts: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
					var indices: PackedInt32Array=arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX]!=null else PackedInt32Array();var count: int=indices.size() if not indices.is_empty() else verts.size()
					var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES);var emitted:=0
					for i in range(0,count,3):
						var poly: Array=[]
						for j in 3:poly.append(transform*verts[indices[i+j] if not indices.is_empty() else i+j])
						for fragment: Array in subtract(poly,cut):
							for k in range(1,fragment.size()-1):
								for vertex: Vector3 in [fragment[0],fragment[k],fragment[k+1]]:st.add_vertex(transform.affine_inverse()*vertex);emitted+=1
					if emitted>0:
						st.generate_normals();st.commit(mesh)
						mesh.surface_set_material(mesh.get_surface_count()-1,node.mesh.surface_get_material(surface))
				if mesh.get_surface_count()>0:node.mesh=mesh
				else:node.visible=false
			elif node is MultiMeshInstance3D:
				# Decorative ground-storey windows/screens would otherwise float in the opening.
				var mm: MultiMesh=node.multimesh.duplicate();node.multimesh=mm
				for i in mm.instance_count:
					var local: Transform3D=mm.get_instance_transform(i)
					var transform: Transform3D=root.global_transform.affine_inverse()*node.global_transform*local
					if (transform*mm.mesh.get_aabb()).intersects(cut):mm.set_instance_transform(i,Transform3D(Basis.IDENTITY.scaled(Vector3.ZERO),local.origin))
