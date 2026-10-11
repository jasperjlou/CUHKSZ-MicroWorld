extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("tb-mall-v42",Vector3(-12,7,-192),Vector3(-54,11,-229))
	await capture("tb-depth-v42",Vector3(-175,100,-151),Vector3(-87,6,-220))
	await capture("tb-court-v42",Vector3(-91,5,-211),Vector3(-71,8,-200))
	await capture("tb-rear-walk-v42",Vector3(-145,5,-188),Vector3(-127,5,-235))
	await fixture(Vector3(-38,2.54,-207),[
		[Vector3(-54,2.24,-207),"B relocated sheltered entrance"],
		[Vector3(-76,2.24,-207),"B inner corridor"],
		[Vector3(-88,2.24,-207),"B corridor to deeper court"],
		[Vector3(-110,2.24,-207),"B court under diagonal wing"],
		[Vector3(-135,2.24,-207),"B rear aperture to perimeter walk"],
		[Vector3(-135,2.24,-181.5),"B rear walk toward gate side"],
		[Vector3(-135,2.24,-167),"B rear path meets existing gate avenue"],
		[Vector3(-135,2.24,-181.5),"gate link return"],
		[Vector3(-39,2.24,-181.5),"B gate-side outer walk to mall"]])
	await fixture(Vector3(-39,2.54,-258.5),[
		[Vector3(-135,2.24,-258.5),"B deeper-campus side outer walk"],
		[Vector3(-135,2.24,-220),"B continuous rear perimeter"],
		[Vector3(-135,2.24,-258.5),"B rear return"],
		[Vector3(-39,2.24,-258.5),"B side walk rejoins mall"],
		[Vector3(-39,2.24,-207),"B unchanged mall edge"],
		[Vector3(-39,2.24,-185),"B mall threshold to gate-side corner"]])
	await fixture(Vector3(-82,2.54,-200.56),[
		[Vector3(-78.5,2.24,-200.56),"B moved stair foot"],
		[Vector3(-61.5,7.165,-200.56),"B first-floor stair landing"],
		[Vector3(-56,7.165,-200.56),"B landing to shifted inner gallery"],
		[Vector3(-61.5,7.165,-200.56),"B gallery return"],
		[Vector3(-81,2.24,-200.56),"B stair descent"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":3,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"Teaching B deeper footprint, interior-to-rear loop, mall edges and shifted stair; fitting not surveyed precision; A/C models not accepted by this check."}
	FileAccess.open("res://tests/artifacts/teaching_b_depth_v42.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TEACHING_B_DEPTH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
