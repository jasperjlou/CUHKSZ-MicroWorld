extends "res://tests/CourtyardRefinementCapture.gd"
## Material-only correction; reuse the completed physical route milestone.
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("rear-road-final",Vector3(138,13,-239),Vector3(139,4,-345))
	await capture("library-ground-wall-final",Vector3(80,3.9,-290),Vector3(96,4,-290))
	var report:={"captures":captures,"failures":failures,"build_ms":world.built_ms,"scope":"Material 26 external granite separated from existing material 24 pressed-wood wall; no collision changes"}
	FileAccess.open("res://tests/artifacts/library_rear_material_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_REAR_MATERIAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
