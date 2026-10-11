extends "res://tests/LibraryLowerLevelCapture.gd"
## Local finish only: inward-facing silence cells and the corrected non-overlapping ceiling.
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-rooms-119-final",wp(33,1.8,-9),wp(27,1.8,-17))
	await capture("library-rooms-cells-final",wp(31.5,1.8,-10),wp(34,1.6,-3))
	await fixture(wp(29,.3,-8),[
		[wp(32,0,-8),"silence cell side aisle"],[wp(32,0,-6),"S101 front"],
		[wp(32,0,-8),"S101 aisle return"],[wp(32,0,-10),"119 side clearance"],
		[wp(32,0,-11.5),"119 final doorway"],[wp(29.7,0,-13.8),"119 final interior"],
		[wp(32,0,-11.5),"119 final exit"]])
	var report:={"captures":captures,"failures":failures,"physical_legs":legs,"build_ms":world.built_ms,"scope":"inward-facing silence-cell frontage and 119 after ceiling cleanup; booth interior not walk-tested"}
	FileAccess.open("res://tests/artifacts/library_rooms_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_ROOMS_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
