extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("zhang-depth-v122",Vector3(-190,99,-359),Vector3(-85,8,-420))
	await capture("zhang-front-v122",Vector3(-20,8,-382),Vector3(-57,10,-430))
	await capture("zhang-court-v122",Vector3(-104,4.1,-411),Vector3(-65,7,-426))
	await capture("cd-rear-v122",Vector3(-142,7,-366),Vector3(-130,4,-419))
	await fixture(Vector3(-135.12,2.54,-360),[
		[Vector3(-135.12,2.24,-363.5),"C rear last corner"],
		[Vector3(-131.14,2.24,-381.5),"C D diagonal rear link"],
		[Vector3(-131.14,2.24,-420),"D deep rear perimeter"],
		[Vector3(-118,2.24,-420),"D rear undercroft entry"],
		[Vector3(-101,2.24,-420),"D deep inner court"],
		[Vector3(-83,2.24,-420),"D court under oblique wing"],
		[Vector3(-69,2.24,-420),"D retained public service doorway"],
		[Vector3(-55,2.24,-420),"D court to retained frontage"],
		[Vector3(-55,2.24,-455),"D south side undercroft"],
		[Vector3(-131.14,2.24,-458.5),"D deeper campus side rear corner"],
		[Vector3(-131.14,2.24,-381.5),"D full rear return"],
		[Vector3(-135.12,2.24,-363.5),"D C rear link return"]])
	await fixture(Vector3(-38.15,2.54,-435),[
		[Vector3(-38.15,2.32,-432),"retained photo stair foot"],
		[Vector3(-38.15,7.165,-415),"retained photo stair head"],
		[Vector3(-41.4,7.165,-415),"first gallery inner bypass"],
		[Vector3(-41.4,7.165,-443),"first gallery to transverse link"],
		[Vector3(-30,6.89,-443),"transverse deck transition"],
		[Vector3(12,6.89,-443),"transverse middle"],
		[Vector3(38,6.89,-443),"transverse stair approach"],
		[Vector3(38,6.89,-441.7),"transverse stair head"],
		[Vector3(38,2.24,-425),"transverse descent"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"fixtures":2,"scope":"D deeper oblique court, C D rear link, retained photo gallery/stair/transverse connection. Not surveyed rear grading or full upper room plan."}
	FileAccess.open("res://tests/artifacts/zhang_depth_v122.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ZHANG_DEPTH_V122 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
