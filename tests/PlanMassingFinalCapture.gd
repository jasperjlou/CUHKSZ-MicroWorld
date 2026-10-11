extends "res://tests/PlanMassingCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("teaching-plan",Vector3(-34,180,-309),Vector3(-65,0,-310))
	await capture("c-oblique",Vector3(-13,43,-283),Vector3(-65,12,-325))
	await capture("b-court",Vector3(-65,5,-220),Vector3(-59,12,-239))
	await capture("a-arcade",Vector3(-45,4,-102),Vector3(-51,4,-130))
	await capture("administration-front",Vector3(3,13,-137),Vector3(74,16,-180))
	await capture("administration-back",Vector3(125,23,-154),Vector3(95,22,-180))
	await capture("administration-terrace",Vector3(111,16.4,-166),Vector3(91,16.7,-181))
	# Only the relocated B/C first-floor stair was not covered by the ground-floor fixtures.
	# B and C share its geometry and dimensions, so use B as the representative physical fixture.
	await fixture(Vector3(-73,2.54,-200.56),[
		[Vector3(-55,7.165,-200.56),"B/C relocated stair ascent"],
		[Vector3(-50.5,7.165,-200.56),"B/C open upper cross-walk"],
		[Vector3(-55,7.165,-200.56),"B/C stair landing return"],
		[Vector3(-73,2.24,-200.56),"B/C relocated stair descent"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"build_ms":world.built_ms,"scope":"final roof/parapet and rear-panel materials; one previously uncovered shared B/C stair, no repetition of 21 passed legs"}
	FileAccess.open("res://tests/artifacts/plan_massing_final.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("PLAN_MASSING_FINAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
