extends "res://tests/LibraryLowerLevelCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-water-fins-final-v48",wp(-29,2,52),wp(-28,5,28))
	await capture("library-pool-anniversary-final-v48",Vector3(-8,19,-214),Vector3(62,13,-294))
	await fixture(Vector3(40,2.54,-308),[
		[Vector3(15,2.24,-308),"final dry approach before water"],
		[Vector3(15,2.24,-329),"final mall bank"],[Vector3(9,2.24,-332),"final courtyard approach"],
		[Vector3(9,2.24,-350),"final link beside sunken court"],
		[Vector3(9,2.24,-332),"final courtyard return"],[Vector3(15,2.24,-329),"final bank corner return"],
		[Vector3(15,2.24,-308),"final mall bank reverse"],[Vector3(40,2.24,-308),"final G approach return"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"build_ms":world.built_ms,"scope":"Only changed front pedestrian route around enlarged reflecting pool; initial pavilion, G doorway and main-stair checks remain unaffected."}
	FileAccess.open("res://tests/artifacts/library_pool_finish_v48.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_POOL_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
