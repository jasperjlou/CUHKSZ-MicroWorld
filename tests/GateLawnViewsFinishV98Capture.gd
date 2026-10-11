extends "res://tests/CourtyardRefinementCapture.gd"

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-lawn-v98-final-layout",Vector3(-4,40,-57),Vector3(0,2.3,-119))
	await capture("gate-lawn-v98-final-avenue",Vector3(-20,4,-109),Vector3(-4,5,-173))
	FileAccess.open("res://tests/artifacts/gate_lawn_v98_views_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"change":"non-colliding rectangular grey stone and removal of fabricated grass sign"},"\t"))
	quit(0 if failures.is_empty() else 1)
