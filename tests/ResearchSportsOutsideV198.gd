extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("sports-street-v198-corner",Vector3(-164,9,-1126),Vector3(-105,2,-1065))
	await capture("sports-street-v198-footway",Vector3(-130.9,.12,-1080),Vector3(-130.9,-.6,-1100))
	var research:Node3D=world.builder.buildings["research"]
	await capture("research-outside-v198-rear",research.to_global(Vector3(66,7,-69)),research.to_global(Vector3(0,1,-43)))
	await capture("research-outside-v198-side",research.to_global(Vector3(-66,5,58)),research.to_global(Vector3(-47,1,-20)))
	FileAccess.open("res://tests/artifacts/research_sports_outside_v198.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":0,"scope":"Sports footway material/tactile strip and visual-only lamps. Research perimeter inspection; no new research geometry or route acceptance."},"\t"))
	print("RESEARCH_SPORTS_V198_DONE");quit(0 if failures.is_empty() else 1)
