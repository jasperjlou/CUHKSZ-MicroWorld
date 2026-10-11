extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false)
	# Retain the structural columns. The ground aisle lies beside the old straight test line.
	await fixture(Vector3(-33,2.54,-733),[
		[Vector3(-36.5,2.24,-733),"wing aisle alignment"],[Vector3(-36.5,2.24,-700),"plus Z wing public lower"],
		[Vector3(-36.5,2.24,-733),"plus Z wing return"],[Vector3(-36.5,2.24,-765),"minus Z wing public lower"],
		[Vector3(-36.5,2.24,-733),"minus Z wing return"],[Vector3(-8.1,2.24,-733),"courtyard street return"]])
	var report: Dictionary={"version":world.data.version,"physical_legs":legs,"failures":failures,"scope":"Final Zhixin lower-wing aisle continuation only; +Z/-Z are model directions, not geographic north/south. Retain initial18 and finish13 passed legs."}
	FileAccess.open("res://tests/artifacts/zhixin_aisle_finish_v54.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ZHIXIN_AISLE_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
