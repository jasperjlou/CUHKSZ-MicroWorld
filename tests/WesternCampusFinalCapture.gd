extends "res://tests/WesternCampusCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("sports-entrance",Vector3(-3,11,-829),Vector3(-1,10,-868))
	await capture("sports-field",Vector3(-12,11,-970),Vector3(-10,11,-914))
	await capture("reception",Vector3(-1,5,-873),Vector3(3,5,-883))
	await capture("old-gate",Vector3(-107,6,-837),Vector3(-132,8,-861))
	await capture("track",Vector3(92,66,-1100),Vector3(-10,4,-1018))
	await capture("district",Vector3(-184,85,-997),Vector3(-25,8,-907))
	print("WESTERN_FINAL_VISUAL ",captures," build_ms=",world.built_ms," failures=",failures)
	quit(0 if failures.is_empty() else 1)
