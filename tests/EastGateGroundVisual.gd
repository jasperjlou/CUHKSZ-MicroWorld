extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-ramp-v38",Vector3(13,5,-29),Vector3(18.5,2,-51))
	var report: Dictionary={"captures":captures,"failures":failures,"build_ms":world.built_ms,"scope":"Replacement of occluded camera only; no model changes or repeated physical tests"}
	FileAccess.open("res://tests/artifacts/east_gate_ground_visual_v38.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("GATE_VISUAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
