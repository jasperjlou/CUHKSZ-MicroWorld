extends "res://tests/TeachingArcadeCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("c-long-hall",Vector3(-47,4,-304),Vector3(-47,6,-344))
	await capture("c-reverse",Vector3(-46,4,-340),Vector3(-47,6,-302))
	await capture("c-court",Vector3(-70,9,-317),Vector3(-49,8,-327))
	await capture("b-lobby",Vector3(-43,4,-207),Vector3(-63,4,-207))
	await fixture(Vector3(-73.4,2.54,-305.56),[
		[Vector3(-55.5,7.165,-305.56),"C retained stair ascent"],[Vector3(-53.8,7.165,-313),"C repaired upper gallery junction"],
		[Vector3(-55.5,7.165,-305.56),"C upper gallery return"],[Vector3(-73.4,2.24,-305.56),"C stair descent"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"build_ms":world.built_ms,"no_teleport_within_each_fixture":true,"scope":"only repaired C stair/gallery junction retested; B exhibition shifted off centre line"}
	FileAccess.open("res://tests/artifacts/teaching_arcade_finish_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TEACHING_ARCADE_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
