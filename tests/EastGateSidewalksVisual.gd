extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-arrival-final-v65",Vector3(-3,5,40),Vector3(1,6,-16))
	await capture("gate-sidewalk-final-v65",Vector3(-10.6,2.1,37),Vector3(-10.5,1,-2))
	await capture("gate-square-stone-final-v65",Vector3(8,2.2,-19),Vector3(0,3.7,-44))
	FileAccess.open("res://tests/artifacts/east_gate_sidewalks_visual_v65.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"scope":"final paving colour and unobstructed views only;no duplicate physical fixture"},"\t"))
	quit()
