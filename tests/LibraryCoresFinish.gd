extends "res://tests/LibraryLowerLevelCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-registered-front-v45",wp(-8,35,70),wp(0,12,6))
	await capture("library-bent-front-v45",wp(-20,8,42),wp(-3,9,26))
	await capture("library-registered-lower-v45",wp(-18,1.8,22),wp(-26,1.8,9))
	await fixture(wp(-18,.3,26),[
		[wp(-18,0,20),"registered lower front doorway"],
		[wp(-18,0,-8),"new lower front to shared hall"],
		[wp(-18,0,26),"lower front return through glazing"]])
	await fixture(wp(5,.3,31),[
		[wp(17,4.4,18),"outdoor stair beside finished lower screen"],
		[wp(18,4.4,10),"2F opening through finished screen"],
		[wp(17,4.4,18),"2F door to outside landing"],
		[wp(5,0,30),"outdoor descent beside screen"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":2,"build_ms":world.built_ms,"scope":"Final front glazing and fin boundaries only; registered 54-leg report remains the core/wing evidence."}
	FileAccess.open("res://tests/artifacts/library_cores_finish_v45.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_CORES_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
