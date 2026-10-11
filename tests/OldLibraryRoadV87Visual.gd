extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("court-bus-road-final-v87",Vector3(-19,4.0,-676.4),Vector3(-62,3.8,-682))
	await capture("old-library-junction-final-v87",Vector3(-12,6.8,-666),Vector3(-31,8,-698))
	await capture("old-library-layout-final-v87",Vector3(-5,57,-623),Vector3(-54,2.5,-685))
	var report:Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"scope":"Visual finish:remove legacy shrubs through path,lower painted bars to asphalt,remove duplicate overlapping library facade and shorten rail to photographed verge.25 unchanged walking legs retained."}
	FileAccess.open("res://tests/artifacts/old_library_visual_v87.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("OLD_LIBRARY_VISUAL_V87 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
