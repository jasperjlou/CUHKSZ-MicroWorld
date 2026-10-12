extends "res://tests/LibraryEntryApproachV117.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-soffit-v146-before",ap(0,7,1.3),ap(0,2.5,2.8))
	var samples:Array=[]
	for pixel:Vector2 in [Vector2(1142,517),Vector2(1142,500),Vector2(1120,518),Vector2(1168,520)]:
		var origin:Vector3=world.overview.project_ray_origin(pixel);var direction:Vector3=world.overview.project_ray_normal(pixel)
		var q:=PhysicsRayQueryParameters3D.create(origin,origin+direction*100);q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q)
		var record:Dictionary={"pixel":str(pixel),"hit":str(hit)}
		if not hit.is_empty():record["path"]=str(hit.collider.get_path())
		samples.append(record)
	FileAccess.open("res://tests/artifacts/library_soffit_v146_diagnosis.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"samples":samples,"captures":captures},"\t"))
	quit()
