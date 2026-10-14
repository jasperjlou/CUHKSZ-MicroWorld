extends "res://tests/LibraryLowerLevelCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(20)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var paving:Node3D=world.find_child("ShawStreetPavingV250",true,false)
	var route:Array=[]
	for r:Dictionary in world.data.routes:
		if r.id=="shaw_corner_link":route=r.points
	var vertices:int=0;var encroaching:int=0;var height_errors:int=0
	for mesh:Node in paving.get_children():
		if not mesh is MeshInstance3D:continue
		var arrays:Array=mesh.mesh.surface_get_arrays(0)
		for p:Vector3 in arrays[Mesh.ARRAY_VERTEX]:
			vertices+=1;var nearest:float=INF;var pos:=Vector2(p.x,p.z)
			for i in range(route.size()-1):
				var a:=Vector2(route[i][0],route[i][2]);var b:=Vector2(route[i+1][0],route[i+1][2])
				nearest=minf(nearest,pos.distance_to(Geometry2D.get_closest_point_to_segment(pos,a,b)))
			if nearest<4.78:encroaching+=1
			if absf(p.y-world.builder.height(p.x,p.z)-.146)>.002:height_errors+=1
	if encroaching>0 or height_errors>0 or vertices==0:failures.append("new paving overlaps asphalt or terrain height mismatch")
	await capture("shaw-paving-v250-corner",Vector3(57,4,-586),Vector3(76,3,-577))
	await capture("shaw-paving-v250-bricks",Vector3(89,4.4,-582),Vector3(86,2.45,-578.8))
	await capture("shaw-paving-v250-stone",Vector3(91,4.4,-578),Vector3(88,2.45,-575.5))
	await capture("shaw-paving-v250-interfaces",Vector3(77,14,-587),Vector3(76,2.5,-576))
	FileAccess.open("res://tests/artifacts/shaw_street_paving_v250.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"vertices":vertices,"encroaching_vertices":encroaching,"height_errors":height_errors,"triangles":paving.get_meta("triangles"),"failures":failures,"scope":"new visual surface road-exclusion/height geometry and4images;collision unchanged,no repeated walking"},"\t"))
	print("SHAW_PAVING_V250 ",JSON.stringify({"vertices":vertices,"encroaching":encroaching,"height_errors":height_errors,"failures":failures}));quit(0 if failures.is_empty() else 1)
