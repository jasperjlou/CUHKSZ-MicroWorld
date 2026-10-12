extends "res://tests/StudentRegisteredV153.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var before=JSON.parse_string(FileAccess.get_file_as_string("res://tests/artifacts/student_finish_v155_collision_before.json"))
	var after=preload("res://tests/StudentCollisionSignature.gd").capture(world)
	if before.sha256!=after.sha256:failures.append("student collision signature changed")
	await capture("student-v155-court-final",pp(165,420,6.2),pp(500,360,7))
	await capture("student-v155-panel-final",pp(260,400,7.1),pp(180,240,6.7))
	FileAccess.open("res://tests/artifacts/student_finish_v155_panel.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"before":before,"after":after,"failures":failures,"captures":captures,"scope":"Correct north-side red panel joints to face the court; all collision unchanged."},"\t"))
	print("STUDENT_FINISH_V155_PANEL ",JSON.stringify({"collision_equal":before.sha256==after.sha256,"failures":failures}));quit(0 if failures.is_empty() else 1)
