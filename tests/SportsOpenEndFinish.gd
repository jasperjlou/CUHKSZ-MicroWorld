extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("sports-open-end-v58",Vector3(74,14,-979),Vector3(40,9,-947))
	await capture("sports-field-profile-v58",Vector3(-10,6,-1044),Vector3(-10,10,-947))
	await capture("sports-terrace-v58",Vector3(49,12,-958),Vector3(34,12,-949))
	await capture("sports-stairwell-v58",Vector3(49,11,-931),Vector3(40,8,-943))
	await fixture(Vector3(38,2.54,-947),[
		[Vector3(49,2.24,-947),"ground clear outer aisle"],[Vector3(49,2.24,-932.5),"outer aisle around low stair soffit"],
		[Vector3(38,2.24,-932.5),"ground stair foot"],[Vector3(38,4.64,-944.5),"first stair half landing"],
		[Vector3(44,4.64,-944.5),"first half landing turn"],[Vector3(44,7.04,-932.5),"first floor arrival"],
		[Vector3(49,7.04,-932.5),"first floor outside stairwell"],[Vector3(49,7.04,-960),"first floor to field-side gallery"],
		[Vector3(19,7.04,-960),"continuous ground-to-gallery connection"],[Vector3(49,7.04,-960),"gallery connection return"],
		[Vector3(49,7.04,-932.5),"first floor outer aisle return"],[Vector3(38,7.04,-932.5),"first floor stair transfer"],[Vector3(38,9.24,-944.5),"second stair half landing"],
		[Vector3(44,9.24,-944.5),"second half landing turn"],[Vector3(44,11.44,-932.5),"upper terrace arrival"],
		[Vector3(49,11.44,-932.5),"outside upper stairwell"],[Vector3(49,11.44,-957),"upper field-view terrace"],
		[Vector3(49,11.44,-932.5),"upper terrace return"],[Vector3(44,11.44,-932.5),"upper descending stair foot"],
		[Vector3(44,9.24,-944.5),"upper descent half landing"],[Vector3(38,9.24,-944.5),"upper descending turn"],
		[Vector3(38,7.04,-932.5),"upper descent to first floor"],[Vector3(44,7.04,-932.5),"lower descending transfer"],
		[Vector3(44,4.64,-944.5),"lower descent half landing"],[Vector3(38,4.64,-944.5),"lower descending turn"],
		[Vector3(38,2.24,-932.5),"ground return"],[Vector3(49,2.24,-932.5),"return around ground stair foot"],[Vector3(49,2.24,-947),"foyer return"],[Vector3(62,2.24,-947),"end exit return"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"Open-end ground entrance, continuous ground-to-third-floor fitted public stairs, recessed terrace and dipped viewing gallery. Ground-to-gallery connection included; retain8 initial dipped-gallery legs. V57 central stair removed after source correction; its old tests superseded."}
	FileAccess.open("res://tests/artifacts/sports_open_end_finish_v58.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SPORTS_OPEN_END_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
