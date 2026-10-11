extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("icc-avenue-v39",Vector3(56,4.0,-112),Vector3(63,4.4,-76))
	await capture("icc-door-bays-v39",Vector3(55,4.0,-99),Vector3(64,4.0,-99))
	await capture("icc-side-apron-v39",Vector3(24,7,-104),Vector3(59,4,-96))
	await capture("ta-mall-seam-v39",Vector3(-30,6,-83),Vector3(-43,3,-130))
	await fixture(Vector3(23,2.54,-98),[
		[Vector3(56,2.24,-98),"ICC side stone approach"],
		[Vector3(60,2.24,-98),"ICC door-row aisle"],
		[Vector3(60,2.24,-58),"ICC lower avenue past door bays"],
		[Vector3(56,2.24,-58),"ICC glazed-wing lower apron"],
		[Vector3(56,2.24,-47),"ICC outer side junction"],
		[Vector3(27,world.builder.height(27,-47),-47),"ICC side path to gate-facing apron"],
		[Vector3(56,2.24,-47),"ICC side path return"],
		[Vector3(56,2.24,-98),"ICC lower avenue return"],
		[Vector3(23,2.24,-98),"ICC side approach return"],
		[Vector3(23,2.24,-80),"ICC public stair approach"],
		[Vector3(39,6.64,-80),"ICC raised terrace retained"],
		[Vector3(49,6.64,-80),"ICC entrance retained above lower envelope"],
		[Vector3(39,6.64,-80),"ICC terrace return"],
		[Vector3(23,2.24,-80),"ICC stair descent retained"]])
	await fixture(Vector3(-30,2.54,-80),[
		[Vector3(-39,2.24,-80),"TA gate-side hardscape join"],
		[Vector3(-39,2.24,-115),"TA continuous mall edge"],
		[Vector3(-48,2.24,-115),"TA arcade threshold"],
		[Vector3(-61,2.24,-115),"TA existing glass portal retained"],
		[Vector3(-39,2.24,-115),"TA portal to mall return"],
		[Vector3(-39,2.24,-146),"TA short-end approach"],
		[Vector3(-50,2.24,-146),"TA short-end stone return"],
		[Vector3(-39,2.24,-146),"TA short-end exit"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":2,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"ICC lower enclosure/avenue/fitted side connections and TA mall seams. No full ICC or TA back-route fidelity claim."}
	FileAccess.open("res://tests/artifacts/entry_side_interfaces_v39.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ENTRY_SIDE_INTERFACES ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
