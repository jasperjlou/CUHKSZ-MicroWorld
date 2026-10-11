extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("sports-open-end-finish-v58",Vector3(72,15,-982),Vector3(38,9,-947))
	await capture("sports-gallery-finish-v58",Vector3(-10,11,-992),Vector3(-10,6,-960))
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"scope":"Visual finish only after roof soffit colour and gallery corner guard closure; no repeated physics."}
	FileAccess.open("res://tests/artifacts/sports_open_end_visual_v58.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SPORTS_OPEN_END_VISUAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
