extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("admin-garden-overview-final-v71",Vector3(177,39,-145),Vector3(131,15,-180))
	await capture("admin-garden-pavilion-final-v71",Vector3(131,17.5,-180),Vector3(152,19.3,-180))
	await capture("admin-garden-downhill-final-v71",Vector3(149,18,-177),Vector3(116,14,-180))
	await capture("admin-garden-road-final-v71",Vector3(143,18,-207),Vector3(123,15,-185))
	FileAccess.open("res://tests/artifacts/admin_garden_visual_v71.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"scope":"final service-path paving material clearance only;physical geometry unchanged"},"\t"))
	print("ADMIN_GARDEN_VISUAL complete");quit(0)
