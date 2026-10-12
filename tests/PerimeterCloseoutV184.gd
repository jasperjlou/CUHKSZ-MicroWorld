extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("perimeter-v184-sports",Vector3(-87,17,-999),Vector3(30,3,-946))
	await capture("perimeter-v184-street",Vector3(-164,9,-1126),Vector3(-105,2,-1065))
	await capture("perimeter-v184-outward",Vector3(-138,5,-1027),Vector3(-257,1,-1025))
	await capture("perimeter-v184-research",Vector3(12,12,-795),Vector3(130,10,-919))
	var edge:Node=world.find_child("SportsWoodlandEdgeV184",true,false)
	FileAccess.open("res://tests/artifacts/perimeter_closeout_v184.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"trees":edge.get_meta("tree_count"),"physical_legs":0,"scope":"Visual margin/ground partition only;same terrain coordinates;exterior apron intentionally abstract"},"\t"))
	print("PERIMETER_V184_DONE");quit(0 if failures.is_empty() else 1)
