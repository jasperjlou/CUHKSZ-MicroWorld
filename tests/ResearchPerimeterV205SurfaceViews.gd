extends "res://tests/ResearchSiteV172.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	rt=world.builder.buildings["research"].global_transform
	await capture("research-perimeter-v205-join-surface",Vector3(46,4,-905),Vector3(44,2.5,-886))
	await capture("research-perimeter-v205-front-surface",rp(-33,7,87),rp(-2,6,44))
	await capture("sports-corner-v205-inspection",Vector3(-166,12,-1132),Vector3(-119,0,-1091))
	FileAccess.open("res://tests/artifacts/research_perimeter_v205_surface_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":0,"scope":"Research visual wearing surface only; retained collision unchanged. Sports corner inspection before next modelling batch."},"\t"))
	print("RESEARCH_PERIMETER_V205_SURFACE ",failures);quit(0 if failures.is_empty() else 1)
