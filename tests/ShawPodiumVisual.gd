extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("shaw-podium-terrace-clean-v51",Vector3(61.3,12.74,-540),Vector3(103.3,14.24,-540))
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"scope":"Removed offset wayfinding signs floating over podium rooms/terrace; minimap destinations retained. No collision changes."}
	FileAccess.open("res://tests/artifacts/shaw_podium_visual_v51.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_PODIUM_VISUAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
