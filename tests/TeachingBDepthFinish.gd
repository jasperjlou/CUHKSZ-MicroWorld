extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("tb-mall-v42",Vector3(-9,18,-196),Vector3(-63,11,-222))
	await capture("tb-depth-v42",Vector3(-175,100,-151),Vector3(-87,6,-220))
	await capture("tb-court-v42",Vector3(-91,5,-211),Vector3(-71,8,-200))
	await capture("tb-rear-walk-v42",Vector3(-134,4.2,-197),Vector3(-128,5,-240))
	await fixture(Vector3(-39,2.54,-207),[
		[Vector3(-53.72,2.24,-207),"relocated B lobby centre"],
		[Vector3(-53.72,2.24,-220),"side opening to promenade corridor"],
		[Vector3(-53.72,2.24,-237),"side corridor exit under glazed end"],
		[Vector3(-53.72,2.24,-220),"side corridor return"],
		[Vector3(-53.72,2.24,-207),"side corridor back to lobby"],
		[Vector3(-65,2.24,-207),"rear lobby opening to court"],
		[Vector3(-88,2.24,-207),"court route after removing false inner tube"],
		[Vector3(-110,2.24,-207),"court to retained rear arcade route"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"Final sideways B corridor and court opening; initial 20-leg report remains valid except old inner-corridor and corridor-to-court descriptions/geometry, replaced here. Rear loop and stair unchanged."}
	FileAccess.open("res://tests/artifacts/teaching_b_depth_finish_v42.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TEACHING_B_DEPTH_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
