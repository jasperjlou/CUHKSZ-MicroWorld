extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("old-library-footway-v252-street",Vector3(-25,3.8,-676.4),Vector3(-53,3.1,-682))
	await capture("old-library-footway-v252-verge",Vector3(-30,3.8,-677),Vector3(-39,2.55,-675.5))
	await capture("old-library-footway-v252-gate",Vector3(-41,5.2,-680),Vector3(-44,2.5,-674))
	await capture("old-library-footway-v252-pavers",Vector3(-38,3.5,-676.8),Vector3(-39.8,2.4,-676.35))
	FileAccess.open("res://tests/artifacts/old_library_footway_v252.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"collision_changed":false,"scope":"photo-linked paving/verge appearance only; retain V214/V215 physical evidence; no new walking claim"},"\t"))
	print("OLD_LIBRARY_FOOTWAY_V252 ",captures.size()," failures=",failures);quit(0 if failures.is_empty() else 1)
