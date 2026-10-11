extends "res://tests/LibraryRearRoadCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("rear-bank-road-final",Vector3(114,4.2,-368),Vector3(110,4,-436))
	await capture("rear-bank-stair-final",Vector3(108,4.2,-405),Vector3(118,5,-405))
	await fixture(site(110,-405)+Vector3.UP*.3,[
		[site(114.3,-405),"bank foot after terrain seam fix"],[Vector3(119.6,5.665,-405),"stair ascent onto top landing"],
		[site(114.2,-405),"stair descent after seam fix"],[site(110,-405),"road return after seam fix"],
		[site(110,-435),"SC road clearance"],[site(120,-475),"Shaw bend clearance"]])
	var report:={"captures":captures,"failures":failures,"physical_legs":legs,"build_ms":world.built_ms,"scope":"terrain seam and stair landing repair; supersedes timed-out ascent in initial 24-leg report, retaining only its 23 non-timeout legs"}
	FileAccess.open("res://tests/artifacts/rear_bank_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("REAR_BANK_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
