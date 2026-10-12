extends "res://tests/StudentRegisteredV153.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var before=JSON.parse_string(FileAccess.get_file_as_string("res://tests/artifacts/student_finish_v155_collision_before.json"))
	var after=preload("res://tests/StudentCollisionSignature.gd").capture(world)
	if before.sha256!=after.sha256:failures.append("student collision signature changed")
	await capture("student-v155-front",pp(-110,630,17),pp(480,360,10))
	await capture("student-v155-court",pp(165,420,6.2),pp(500,360,7))
	await capture("student-v155-recess",pp(-60,230,15.7),pp(50,150,15.2))
	await capture("student-v155-panel",pp(260,400,7.1),pp(180,240,6.7))
	await capture("student-v155-roof",pp(470,480,78),pp(470,360,0))
	FileAccess.open("res://tests/artifacts/student_finish_v155.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"before":before,"after":after,"failures":failures,"captures":captures,"scope":"Visual-only student facade/paving/roof finish. Exact collision signature compared withV154; no repeated walk tests."},"\t"))
	print("STUDENT_FINISH_V155 ",JSON.stringify({"shape_count":after.shape_count,"collision_equal":before.sha256==after.sha256,"failures":failures}));quit(0 if failures.is_empty() else 1)
