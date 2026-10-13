extends "res://tests/ResearchSiteV172.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	rt=world.builder.buildings["research"].global_transform
	await capture("research-perimeter-v205-rear-final",rp(25,2,-54),rp(-58,2.2,-49))
	await capture("research-perimeter-v205-return-final",rp(-81,17,62),rp(-56,0,21))
	await capture("research-perimeter-v205-side-final",rp(-60,1.9,40),rp(-65,3,-42))
	FileAccess.open("res://tests/artifacts/research_perimeter_v205_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":0,"scope":"Smooth forest-ground shader boundary only; collision vertices and accepted routes unchanged."},"\t"))
	print("RESEARCH_PERIMETER_V205_VIEWS ",failures);quit(0 if failures.is_empty() else 1)
