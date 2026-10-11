extends "res://tests/StudentPublicCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("front",Vector3(-8,15,-366),Vector3(68,13,-400))
	await capture("courts",Vector3(4,66,-350),Vector3(72,12,-400))
	await capture("portal",Vector3(40,4.1,-393),Vector3(86,6,-389))
	await capture("yellow-arcade",Vector3(59,4.05,-379.5),Vector3(85,4.1,-378))
	await capture("dining-room",Vector3(69,4,-430),Vector3(78,4,-429))
	var report: Dictionary={"captures":captures,"failures":failures,"build_ms":world.built_ms,"scope":"final yellow mosaic, plain soffits and ground paving; unchanged physical routes reuse the 25 passed legs"}
	FileAccess.open("res://tests/artifacts/student_public_visual_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("STUDENT_PUBLIC_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
