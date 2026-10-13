extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-paving-v199-court",Vector3(-11,1.85,-18),Vector3(3,.15,-35))
	await capture("gate-paving-v199-edge",Vector3(-17.8,1.75,-21),Vector3(-18.9,.12,-25))
	await capture("gate-paving-v199-stair",Vector3(7,1.8,-36),Vector3(0,2.7,-53))
	await capture("gate-paving-v199-lawn-next",Vector3(-20,4,-109),Vector3(-4,3,-157))
	FileAccess.open("res://tests/artifacts/east_gate_paving_v199.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":0,"scope":"New granite materials and visual slot drain at inner East Gate square. Existing terrain and collision unchanged; lawn view inspects next section."},"\t"))
	print("GATE_PAVING_V199_DONE");quit(0 if failures.is_empty() else 1)
