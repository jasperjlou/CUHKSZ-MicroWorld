extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("zhixin-roof-final-v83",Vector3(-30,49,-732),Vector3(-55,19,-732))
	await capture("daoyuan-rear-final-v83",Vector3(-59,31,-715),Vector3(-95,19,-733))
	var report:Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"scope":"Visual-only final: roof weathering and cooling tower clearance; V83 ground routes unchanged."}
	FileAccess.open("res://tests/artifacts/rear_roof_visual_v83.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("REAR_ROOF_VISUAL_V83 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
