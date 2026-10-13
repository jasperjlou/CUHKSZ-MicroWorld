extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("mall-paving-v200-gate",Vector3(-20,4,-109),Vector3(-4,3,-157))
	await capture("mall-paving-v200-admin",Vector3(32,4,-191),Vector3(53,2.4,-176))
	await capture("mall-paving-v200-frame",Vector3(-45,48,-216),Vector3(10,2.3,-181))
	await capture("mall-paving-v200-pool",Vector3(14,4,-321),Vector3(16,2.5,-285))
	await capture("mall-paving-v200-library-side",Vector3(43,4,-333),Vector3(50,2.5,-317))
	await capture("mall-paving-v200-colonnade",Vector3(35,4.05,-396.5),Vector3(-32,3,-396.5))
	await capture("mall-paving-v200-grass-drain",Vector3(-7,4.1,-396.5),Vector3(-27,2.4,-424))
	FileAccess.open("res://tests/artifacts/mall_paving_v200.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":0,"scope":"Continuous ground appearance from gate lawn through admin to library/white colonnade; source-informed inlay returns. No collision/grade changes."},"\t"))
	print("MALL_PAVING_V200_DONE");quit(0 if failures.is_empty() else 1)
