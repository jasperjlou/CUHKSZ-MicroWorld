extends "res://tests/ShawWestDetailCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("public-room",Vector3(149,4,-623),Vector3(144,4,-613))
	await fixture(Vector3(127,2.54,-640),[
		[Vector3(123,2.24,-640),"outside front column line"],[Vector3(123,2.24,-629.5),"outer stair forecourt"],
		[Vector3(126,2.24,-629.5),"outer stair foot"],[Vector3(141.6,7.165,-629.5),"outer stair ascent"],
		[Vector3(145,7.165,-629.5),"podium rail opening"],[Vector3(145,7.165,-658),"open podium"],
		[Vector3(145,7.165,-629.5),"podium return"],[Vector3(141.6,7.165,-629.5),"stair landing return"],
		[Vector3(126,2.24,-629.5),"outer stair descent"],[Vector3(121,2.24,-640),"entrance path return"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"build_ms":world.built_ms,"scope":"Remaining stair/podium routes only, with approach routed outside front column line; earlier six ground-floor legs retained"}
	FileAccess.open("res://tests/artifacts/shaw_west_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_WEST_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
