extends "res://tests/StudentTerraceCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("student-court-material-v49",wp(1,6.2,39),wp(0,10,-12))
	await capture("student-front-material-v49",wp(8,12,83),wp(0,11,5))
	var report: Dictionary={"captures":captures,"failures":failures,"scope":"Final surface-kind correction only: exterior gray brick, inner terracotta and yellow mosaic. No collision change; V49 physical reports retained."}
	FileAccess.open("res://tests/artifacts/student_terraces_visual_v49.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("STUDENT_TERRACE_VISUAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
