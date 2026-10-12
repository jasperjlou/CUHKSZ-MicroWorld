extends "res://tests/LibraryEntryApproachV117.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-soffit-v146-emission-diagnosis",ap(0,7,1.3),ap(0,2.5,2.8))
	var samples:Array=[]
	for pixel:Vector2 in [Vector2(1142,517),Vector2(1142,500),Vector2(1120,518),Vector2(1168,520)]:
		var origin:Vector3=world.overview.project_ray_origin(pixel);var direction:Vector3=world.overview.project_ray_normal(pixel)
		var q:=PhysicsRayQueryParameters3D.create(origin,origin+direction*100);q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q)
		var record:Dictionary={"pixel":str(pixel),"hit":str(hit)}
		if not hit.is_empty():record["path"]=str(hit.collider.get_path())
		var luminous:Array=[]
		for mesh:MultiMeshInstance3D in world.find_children("*","MultiMeshInstance3D",true,false):
			if not mesh.material_override is ShaderMaterial or mesh.material_override.get_shader_parameter("surface_kind")!=17:continue
			for i in mesh.multimesh.instance_count:
				var xf:Transform3D=mesh.global_transform*mesh.multimesh.get_instance_transform(i);var inv:=xf.affine_inverse()
				var crossing=AABB(Vector3(-.5,-.5,-.5),Vector3.ONE).intersects_segment(inv*origin,inv*(origin+direction*100))
				if crossing!=null:luminous.append({"node":str(mesh.get_path()),"instance":i,"centre":str(xf.origin),"distance":origin.distance_to(xf*crossing)})
		record["emissive_intersections"]=luminous
		var geometry:Array=[]
		for mesh:MeshInstance3D in world.find_children("*","MeshInstance3D",true,false):
			if mesh.mesh==null:continue
			var inv:=mesh.global_transform.affine_inverse();var ro:Vector3=inv*origin;var rd:Vector3=(inv*(origin+direction)-ro).normalized()
			if mesh.mesh.get_aabb().intersects_segment(ro,ro+rd*100)==null:continue
			for si in mesh.mesh.get_surface_count():
				var arrays:=mesh.mesh.surface_get_arrays(si);var vertices:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX];var indices:PackedInt32Array=arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX]!=null else PackedInt32Array()
				var count:int=indices.size() if not indices.is_empty() else vertices.size()
				for i in range(0,count,3):
					var a:Vector3=vertices[indices[i] if not indices.is_empty() else i];var b:Vector3=vertices[indices[i+1] if not indices.is_empty() else i+1];var c:Vector3=vertices[indices[i+2] if not indices.is_empty() else i+2]
					var hit_point=Geometry3D.ray_intersects_triangle(ro,rd,a,b,c)
					if hit_point!=null:geometry.append({"path":str(mesh.get_path()),"distance":origin.distance_to(mesh.global_transform*hit_point),"material":str(mesh.material_override)})
		geometry.sort_custom(func(a:Dictionary,b:Dictionary)->bool:return a.distance<b.distance)
		record["render_mesh_hits"]=geometry.slice(0,6)
		if not hit.is_empty():
			var sun:DirectionalLight3D=world.find_children("*","DirectionalLight3D",true,false)[0]
			var start:Vector3=hit.position+hit.normal*.005
			var sun_query:=PhysicsRayQueryParameters3D.create(start,start+sun.global_basis.z*100)
			var occluder=world.get_world_3d().direct_space_state.intersect_ray(sun_query)
			record["sun_hit"]=str(occluder);record["sun_path"]=str(occluder.collider.get_path()) if not occluder.is_empty() else "none"
		samples.append(record)
	FileAccess.open("res://tests/artifacts/library_soffit_v146_mesh_diagnosis.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"samples":samples,"captures":captures},"\t"))
	quit()
