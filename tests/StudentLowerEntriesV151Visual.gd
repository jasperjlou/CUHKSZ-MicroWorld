extends "res://tests/StudentLowerEntriesV151.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("student-lower-v151-court-filtered",wp(0,2,20),wp(-1,3,11))
	await capture("student-lower-v151-threshold-filtered",wp(-4.8,1.75,9),wp(-4.8,1.75,17))
	await capture("student-lower-v151-section-filtered",wp(2,8,43),wp(-1,10,-13))
	FileAccess.open("res://tests/artifacts/student_lower_entries_v151_visual.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"scope":"Only mosaic shader changed; no collision or route changes; no physical walks rerun"},"\t"))
	quit(0 if failures.is_empty() else 1)
