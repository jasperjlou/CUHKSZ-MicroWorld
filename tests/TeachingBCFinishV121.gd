extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("bc-v121-c-floor-final",Vector3(-46.5,4.0,-304),Vector3(-48.0,3.0,-335))
	await capture("bc-v121-b-deck",Vector3(-45.8,9.0,-192),Vector3(-55,7.1,-213))
	await capture("bc-v121-c-awning",Vector3(-26,6.2,-333),Vector3(-43,6,-343))
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"scope":"Visual-only follow-up after clipping noncolliding C courtyard/apron overlays away from the long-strip arcade floor; no physics changes since 24 passing legs."}
	FileAccess.open("res://tests/artifacts/teaching_bc_v121_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	quit(0 if failures.is_empty() else 1)
