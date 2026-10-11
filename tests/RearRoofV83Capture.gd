extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("daoyuan-rear-screen-v83",Vector3(-59,31,-715),Vector3(-95,19,-733))
	await capture("zhixin-roof-plant-v83",Vector3(-14,58,-781),Vector3(-53,19,-733))
	await capture("rear-wing-roof-relation-v83",Vector3(-40,64,-681),Vector3(-81,14,-733))
	await capture("daoyuan-rear-ground-v83",Vector3(-72,4.3,-755),Vector3(-95,16,-737))
	await fixture(Vector3(-71,2.54,-775),[
		[Vector3(-71,2.24,-690),"rear aisle towards Shaw-end junction"],
		[Vector3(-76,2.24,-682),"Shaw-end street connection"],
		[Vector3(-71,2.24,-700),"return to rear aisle"],
		[Vector3(-71,2.24,-733),"rear screen ground sightline"],
		[Vector3(-71,2.24,-775),"clock-end return"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"DaoYuan upper rear screen and Zhixin service roof; one continuous affected-side ground fixture. Unseen lower plan, measured heights and whole-campus fidelity remain unresolved."}
	FileAccess.open("res://tests/artifacts/rear_roof_v83.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("REAR_ROOF_V83 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
