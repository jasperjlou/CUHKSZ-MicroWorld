extends "res://tests/CourtyardRefinementCapture.gd"
func wp(x: float,y: float,z: float) -> Vector3:return Vector3(84.3-z,2.24+y,-540+x)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false)
	await fixture(wp(-6.1,3.0,16),[
		[wp(-6.1,.45,23.3),"lower stair descent beyond guard end"],
		[wp(-10,.45,23.3),"ground stair clear landing"],[wp(-10,.45,20),"ground hall around stair"],
		[wp(-20,.45,20),"inside yellow portal"],[wp(-20,.45,28),"yellow portal return"],
		[wp(-20,0,36),"front steps to avenue"]])
	var report: Dictionary={"version":world.data.version,"failures":failures,"physical_legs":legs,"scope":"Local completion of lower stair return: continue past guard endpoint before turning, then leave through the portal. No geometry changed after connections report."}
	FileAccess.open("res://tests/artifacts/shaw_podium_exit_v51.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_PODIUM_EXIT ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
