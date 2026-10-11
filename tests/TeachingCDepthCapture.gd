extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("tc-mall-v43",Vector3(-9,18,-301),Vector3(-63,11,-326))
	await capture("tc-depth-v43",Vector3(-177,110,-259),Vector3(-86,6,-325))
	await capture("tc-entry-v43",Vector3(-43,4.1,-339),Vector3(-60,4,-343))
	await capture("tc-court-v43",Vector3(-84,4.1,-315),Vector3(-71,8,-306))
	await capture("bc-rear-link-v43",Vector3(-135,4.1,-277),Vector3(-131,4,-245))
	await fixture(Vector3(-39,2.54,-343),[
		[Vector3(-53,2.24,-343),"C arcade entrance"],
		[Vector3(-59,2.24,-340),"C diagonal vestibule"],
		[Vector3(-86.62,2.24,-327.88),"C diagonal hall middle"],
		[Vector3(-119,2.24,-313.4),"C diagonal hall rear exit"],
		[Vector3(-135.12,2.24,-312.76),"C rear exit to perimeter"],
		[Vector3(-135.12,2.24,-286.5),"C rear walk toward B"],
		[Vector3(-135.12,2.24,-258.5),"C to B continuous rear link"],
		[Vector3(-135.12,2.24,-272.5),"B rear link return to junction"],
		[Vector3(-39,2.24,-272.5),"B C gap transverse path to mall"]])
	await fixture(Vector3(-86.62,2.54,-327.88),[
		[Vector3(-84.988,2.24,-324.229),"C hall side opening"],
		[Vector3(-82.947,2.24,-319.665),"C side opening into court"],
		[Vector3(-78.62,2.24,-313),"C court circulation"],
		[Vector3(-76,2.24,-305.56),"C court to stair approach"],
		[Vector3(-73,2.24,-305.56),"C stair foot"],
		[Vector3(-56,7.165,-305.56),"C stair upper landing"],
		[Vector3(-53,7.165,-305.56),"C retained high arcade gallery"],
		[Vector3(-56,7.165,-305.56),"C gallery return"],
		[Vector3(-76,2.24,-305.56),"C stair descent"]])
	await fixture(Vector3(-39,2.54,-286.5),[
		[Vector3(-135.12,2.24,-286.5),"C gate-side perimeter"],
		[Vector3(-135.12,2.24,-363.5),"C full rear perimeter"],
		[Vector3(-39,2.24,-363.5),"C deeper-side perimeter to mall"],
		[Vector3(-39,2.24,-343),"C mall edge to entrance"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":3,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"C high arcade, diagonal public hall, court opening, first-floor stair and B/C perimeter connection; fitted geometry, not full room-plan or rear-grade acceptance."}
	FileAccess.open("res://tests/artifacts/teaching_c_depth_v43.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TEACHING_C_DEPTH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
