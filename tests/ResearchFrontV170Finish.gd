extends "res://tests/ResearchFrontV170.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	# At x21 the arc reaches z33.804; the initial z35 probe was outside, not a missing floor.
	probe(rp(21,20,33.3),rp(21,19,33.3),true,"inside curved slab edge",checks)
	probe(rp(21,20,35),rp(21,19,35),false,"outside curved slab edge stays empty",checks)
	await capture("research-v170-corner-final",rp(80,25,60),rp(25,32,27))
	await capture("research-v170-garden-final",rp(-14,17,-3),rp(19,35,26))
	FileAccess.open("res://tests/artifacts/research_front_v170_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"captures":captures,"failures":failures,"physics_geometry_changed":false,"reason":"Correct out-of-footprint diagnostic; move courtyard mullions outward visually and corner camera to avoid tower occlusion; retain16walks"},"\t"))
	print("RESEARCH_V170_FINISH ",JSON.stringify({"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
