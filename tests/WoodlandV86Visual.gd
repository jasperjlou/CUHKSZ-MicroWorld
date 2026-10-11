extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("woodland-downhill-final-v86",Vector3(-29,3.48,-457),Vector3(-30,2,-479))
	await capture("woodland-court-final-v86",Vector3(-69,3.4,-484),Vector3(-88,4,-496))
	await capture("woodland-overview-final-v86",Vector3(-52,39,-457),Vector3(-32,1.8,-480))
	var report:Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"scope":"Visual-only miter paving joins,soil contour tessellation,and solid-looking stair supports;physical terrain and stair ramp unchanged."}
	FileAccess.open("res://tests/artifacts/woodland_visual_v86.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("WOODLAND_VISUAL_V86 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
