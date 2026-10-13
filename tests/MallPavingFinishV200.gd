extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("mall-paving-v200-final-pool",Vector3(14,4,-321),Vector3(16,2.5,-285))
	await capture("mall-paving-v200-final-library-side",Vector3(43,4,-333),Vector3(50,2.5,-317))
	var b:Node3D=world.builder.buildings["library"]
	await capture("mall-paving-v200-final-gallery",b.to_global(Vector3(-39,2.8,29)),b.to_global(Vector3(-24,1.8,23)))
	FileAccess.open("res://tests/artifacts/mall_paving_finish_v200.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":0,"scope":"Moved shore grate onto source-observed light axis and unified library apron/gallery grey tone. Geometry and collision unchanged."},"\t"))
	print("MALL_PAVING_V200_FINISH");quit(0 if failures.is_empty() else 1)
