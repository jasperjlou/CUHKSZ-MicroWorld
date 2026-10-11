extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await fixture(Vector3(44,2.54,-838),[
		[Vector3(44,2.24,-833),"around Research stair north edge"],[Vector3(0,2.24,-833),"existing clear forecourt crossing"],
		[Vector3(0,2.24,-838),"crossroad junction"],[Vector3(-45,2.24,-838),"crossroad beside Hall"],
		[Vector3(-75,2.24,-838),"crossroad towards old south gate"],[Vector3(-45,2.24,-838),"crossroad return west"],
		[Vector3(0,2.24,-838),"crossroad return junction"]])
	var report:Dictionary={"version":world.data.version,"physical_legs":legs,"failures":failures,"scope":"Route-only continuation around existing Research stair north edge; retains8 final Hall entry legs and3 clear crossroad collision rays. No building obstacle removed."}
	FileAccess.open("res://tests/artifacts/hall_crossroad_finish_v62.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("HALL_CROSSROAD_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
