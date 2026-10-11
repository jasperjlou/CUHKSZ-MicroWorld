extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("four-arch-final-v84",Vector3(-12,6,-486),Vector3(0,5,-503))
	await capture("pond-stairs-final-v84",Vector3(0,4,-505),Vector3(0,1.2,-559))
	await capture("pond-bank-final-v84",Vector3(-19,3.3,-538),Vector3(-2,1,-562))
	await capture("pond-overview-final-v84",Vector3(-39,43,-511),Vector3(0,1,-549))
	var report:Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"scope":"Final square grass-joint landing material and tree braces;route geometry unchanged from V84 full fixture."}
	FileAccess.open("res://tests/artifacts/pavilion_pond_visual_v84.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("PAVILION_VISUAL_V84 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
