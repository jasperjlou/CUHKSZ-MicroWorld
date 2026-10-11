extends "res://tests/LibraryLowerLevelCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-exterior-entry-v44",wp(-3,12,42),wp(15,4,18))
	await capture("library-second-stair-v44",wp(14,6.1,10),wp(1,8,0))
	await capture("library-third-void-v44",wp(16,10.6,-8),wp(-1,6.4,7))
	await capture("library-lower-under-entry-v44",wp(14,1.8,17),wp(23,1.8,7))
	await fixture(wp(4,.3,32),[
		[wp(5,0,30),"outside stair foot"],
		[wp(17,4.4,18),"outside stair to second floor"],
		[wp(18,4.4,10),"2F glazed entrance"],
		[wp(7,4.4,9),"2F arrival hall"],
		[wp(0,4.4,9),"2F indoor stair foot"],
		[wp(11.2,8.8,-2.2),"2F to 3F diagonal ascent"],
		[wp(15,8.8,-4),"3F reading floor"],
		[wp(11.2,8.8,-2.2),"3F back to public stair"],
		[wp(0,4.4,9),"3F to 2F descent"],
		[wp(7,4.4,9),"2F arrival return"],
		[wp(18,4.4,10),"2F door return"],
		[wp(17,4.4,18),"outdoor upper landing"],
		[wp(5,0,30),"outdoor stair descent"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"Outdoor entry G to 2F and distinct 2F to 3F diagonal public seating stair; lower hall retained. Metric anchors remain fitted; full plan registration/cores unfinished."}
	FileAccess.open("res://tests/artifacts/library_entry_levels_finish_v44.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_ENTRY_LEVELS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
