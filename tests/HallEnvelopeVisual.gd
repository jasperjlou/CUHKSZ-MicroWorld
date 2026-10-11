extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("hall-rear-panels-finish-v62",Vector3(-74,23,-930),Vector3(-18,11,-919))
	var report:Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"scope":"camera correction only; no geometry or physical route rerun"}
	FileAccess.open("res://tests/artifacts/hall_envelope_visual_v62.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("HALL_ENVELOPE_VISUAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
