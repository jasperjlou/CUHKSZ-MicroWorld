extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(15);await RenderingServer.frame_post_draw
	var filename:="lower-integration-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("main-lawn",Vector3(-190,180,-12),Vector3(20,0,-275))
	await capture("central-court",Vector3(-9,7,-300),Vector3(72,10,-352))
	await capture("library-pool",Vector3(109,5,-361),Vector3(76,16,-291))
	await capture("lower-district",Vector3(-245,220,-490),Vector3(14,0,-780))
	await capture("teaching-row",Vector3(-6,8,-160),Vector3(-55,14,-337))
	await capture("student-approach",Vector3(6,4,-420),Vector3(80,12,-400))
	var report: Dictionary={"captures":captures,"failures":failures,"build_ms":world.built_ms,"scope":"District-scale integration review after versions 12-23; visual only, no traversal reruns"}
	FileAccess.open("res://tests/artifacts/lower_campus_integration.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LOWER_INTEGRATION ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
