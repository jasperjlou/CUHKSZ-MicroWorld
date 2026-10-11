extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("hall-portal-canopy-finish-v62",Vector3(44,8,-884),Vector3(18,10,-897))
	await capture("hall-gap-finish-v62",Vector3(-4,25,-941),Vector3(-14,8,-918))
	await capture("hall-rear-glass-finish-v62",Vector3(-64,10,-830),Vector3(-39,9,-850))
	await fixture(Vector3(44,2.54,-890),[
		[Vector3(30,2.24,-890),"canopy portal approach"],[Vector3(28.8,2.24,-890),"covered walkway entry"],
		[Vector3(28.8,2.24,-927),"covered walkway full length"],[Vector3(21,2.24,-928),"canopy to Complex forecourt"],
		[Vector3(21,2.24,-936),"Complex service doorway"],[Vector3(21,2.24,-928),"service doorway return"],
		[Vector3(28.8,2.24,-927),"covered return start"],[Vector3(28.8,2.24,-890),"covered return to Hall"],
		[Vector3(30,2.24,-890),"Hall stair approach retained"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"Final relocated canopy joins rotated Hall portal to Complex; only affected covered walk/service-entry legs; earlier registered Hall perimeter and reception legs retained if unaffected."}
	FileAccess.open("res://tests/artifacts/hall_canopy_finish_v62.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("HALL_CANOPY_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
