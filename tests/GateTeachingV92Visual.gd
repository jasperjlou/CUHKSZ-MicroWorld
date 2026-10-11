extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-side-landing-finish-v92",Vector3(-13,5.7,-58),Vector3(-17.3,1.4,-44))
	FileAccess.open("res://tests/artifacts/gate_teaching_visual_v92.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"failures":failures,"scope":"Noncollision stone head landing finish;final21 waypoint checks retained including20 moving segments"},"\t"))
	quit(0 if failures.is_empty() else 1)
