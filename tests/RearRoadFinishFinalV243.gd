extends "res://tests/LibraryLowerLevelCapture.gd"
const B=preload("res://world/visual_campus/VisualCampusBuilder.gd")
const F=preload("res://world/visual_campus/RearRoadFinish.gd")
const Bank243=preload("res://world/visual_campus/RearRoadBank.gd")
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(20)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var builder=B.new();builder.data=world.data
	for r:Dictionary in world.data.routes:
		if r.id=="library_rear_shaw_avenue":builder.rear_route=r.points
		if r.id=="east_crossroad":builder.garden_rear_route=r.points
	builder.research_site_transform=preload("res://world/visual_campus/ResearchSite.gd").placement(world.data)
	var checks:Array=[];var samples:int=0;var max_error:float=0.0
	var vs:PackedVector3Array=F.strip(builder,builder.rear_route,F.FIRST,F.LAST,.85,.06,.132)
	for p:Vector3 in vs:
		max_error=maxf(max_error,absf(p.y-builder.height(p.x,p.z)-.132));samples+=1
	checks.append({"case":"drain vertices follow retained terrain profile","samples":samples,"max_error":max_error,"valid":max_error<.0001})
	if max_error>=.0001:failures.append("drain vertex grade")
	await capture("rear-road-v243-final-overview",Vector3(130,10,-345),Vector3(138,8,-285))
	await capture("rear-road-v243-final-drain",Vector3(138.5,7.85,-320),Vector3(141,6.3,-306))
	var x:float=Bank243.toe(-313,builder.rear_route)
	await capture("rear-road-v243-final-stair",Vector3(x-3,8.5,-317),Vector3(x+2,8,-313))
	FileAccess.open("res://tests/artifacts/rear_road_finish_final_v243.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"checks":checks,"failures":failures,"scope":"Visual grading only; unchanged collision. No new walking or camera-sweep results; absolute grade and source date remain fitted/unknown."},"\t"))
	print("REAR_ROAD_FINISH_FINAL_V243 ",JSON.stringify({"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
