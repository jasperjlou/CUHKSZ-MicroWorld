extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-exterior-v192-final-paving",Vector3(29,1.8,44),Vector3(29,3,98))
	FileAccess.open("res://tests/artifacts/east_gate_exterior_final_v192.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"failures":failures,"scope":"Final noncollision old asphalt clipping;reuse accepted seam physics"},"\t"))
	quit(0 if failures.is_empty() else 1)
