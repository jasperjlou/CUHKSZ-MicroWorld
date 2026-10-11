extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("hall-daoyuan-passage-finish-v62",Vector3(-57,7,-832.8),Vector3(-15,4,-833))
	await capture("hall-final-layout-v62",Vector3(-100,95,-990),Vector3(-10,8,-910))
	await fixture(Vector3(-47,2.54,-928),[
		[Vector3(-47,2.24,-833),"rear promenade to retaining corner"],[Vector3(-10,2.24,-833),"flat passage beneath DaoYuan retaining wall"],
		[Vector3(30,2.24,-833),"Hall side to front corner"],[Vector3(44,2.24,-833),"outer forecourt corner"],
		[Vector3(44,2.24,-928),"full front-side bypass"],[Vector3(-10,2.24,-928),"between-hall return"],
		[Vector3(-10,2.24,-947),"Complex open ground passage"],[Vector3(-10,2.24,-965),"Complex field exit"],
		[Vector3(-10,2.24,-970),"field edge connection"]])
	await fixture(Vector3(-14,2.54,-827),[
		[Vector3(-18,2.24,-827),"DaoYuan stair foot retained"],[Vector3(-38,4.64,-827),"DaoYuan upper landing retained"],
		[Vector3(-18,2.24,-827),"DaoYuan stair return retained"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"V62 continuation after existing DaoYuan earth slope pulled behind retaining wall;Hall corner and remaining field route,plus neighbouring terrace stair;prior12 registered Hall and9 canopy legs retained."}
	FileAccess.open("res://tests/artifacts/hall_corner_finish_v62.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("HALL_CORNER_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
