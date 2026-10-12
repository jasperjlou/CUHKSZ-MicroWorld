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
		samples.append(record)
	FileAccess.open("res://tests/artifacts/library_soffit_v146_emission.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"samples":samples,"captures":captures},"\t"))
	quit()
