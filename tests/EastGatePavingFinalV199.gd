extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-paving-v199-final-court",Vector3(-11,1.85,-18),Vector3(3,.15,-35))
	await capture("gate-paving-v199-final-edge",Vector3(-17.8,1.75,-21),Vector3(-18.9,.12,-25))
	await capture("gate-paving-v199-final-stair",Vector3(7,1.8,-36),Vector3(0,2.7,-53))
	await capture("gate-paving-v199-final-hatch",Vector3(12,6,-105),Vector3(7,2.3,-94))
	FileAccess.open("res://tests/artifacts/east_gate_paving_final_v199.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":0,"scope":"Final granite grain, source-led drain, unsubstantiated square sign hidden and hatch returned within lawn. No physics changes."},"\t"))
	print("GATE_PAVING_V199_FINAL");quit(0 if failures.is_empty() else 1)
