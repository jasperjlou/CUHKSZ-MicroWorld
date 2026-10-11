extends "res://tests/StartZoneStreetCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("avenue",Vector3(6.2,4,-748),Vector3(0,5,-666))
	await capture("main-square",Vector3(-13,6,-748),Vector3(-102,9,-732))
	await capture("district",Vector3(-145,101,-630),Vector3(-8,2,-734))
	print("START_STREET_FINISH ",JSON.stringify({"captures":captures,"failures":failures,"build_ms":world.built_ms}));quit(0 if failures.is_empty() else 1)
