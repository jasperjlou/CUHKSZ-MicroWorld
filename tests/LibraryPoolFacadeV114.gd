extends "res://tests/LibraryUpperPlanV110.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-pool-facade-v114-shell",wp(66,49,86),wp(-1,14,3))
	await capture("library-pool-facade-v114-water",wp(-22,16,98),wp(-15,16,26))
	await capture("library-pool-facade-v114-reveals",pp(570,1175,18.3),pp(650,975,18.7))
	var checks:Array=[];var boundary:=Plan.outline()
	var route:Array=[]
	for p in [[550,920],[600,932],[645,942],[685,960],[645,942],[600,932],[550,920]]:route.append([pp(p[0],p[1],12.8),"4F curved window aisle "+str(p)])
	await fixture(pp(520,920,13.1),route)
	# Representative glazing on each window family and all three upper levels.
	for segment in [[22,25,.18],[25,30,7.5/15]]:
		var length:float=0
		for i in range(segment[0],segment[1]):length+=boundary[i].distance_to(boundary[i+1])
		var distance:float=length*segment[2]
		for i in range(segment[0],segment[1]):
			var a:Vector2=boundary[i];var b:Vector2=boundary[i+1];var edge:=a.distance_to(b)
			if distance>edge:distance-=edge;continue
			var p:=a.lerp(b,distance/edge);var normal:=Vector2(-(b-a).y,(b-a).x).normalized()
			for y in [14.8,18.8,22.8]:
				var q=PhysicsRayQueryParameters3D.create(wp(p.x+normal.x*1.3,y,p.y+normal.y*1.3),wp(p.x-normal.x*1.3,y,p.y-normal.y*1.3));q.exclude=[world.player.get_rid()]
				var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var ok:bool=not hit.is_empty()
				checks.append({"case":"closed facade "+str(segment[0])+" y="+str(y),"valid":ok})
				if not ok:failures.append("facade collider "+str(segment)+str(y))
			break
	var report={"version":world.data.version,"checks":checks,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"Changed front windows/collision,4F shelf aisle and exterior only; courtyard/pool global placement remains unresolved"}
	FileAccess.open("res://tests/artifacts/library_pool_facade_v114.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_POOL_FACADE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
