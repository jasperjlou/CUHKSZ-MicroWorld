extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("shaw-corner-plan-final-v50",Vector3(-15,105,-650),Vector3(72,3,-587))
	await capture("shaw-title-stone-final-v50",Vector3(57,4.6,-593),Vector3(75,6,-571))
	await capture("shaw-rear-junction-final-v50",Vector3(124,35,-606),Vector3(108,3,-576))
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"scope":"Visual finish only: natural stone material, low planting and removal of two noncolliding obsolete verge trees; walking geometry unchanged."}
	FileAccess.open("res://tests/artifacts/shaw_corner_visual_v50.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_CORNER_VISUAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
