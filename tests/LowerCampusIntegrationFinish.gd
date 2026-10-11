extends "res://tests/LowerCampusIntegrationCapture.gd"
var render_samples: Array=[]
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	await super.capture(label,eye,target)
	render_samples.append({"view":label,"draw_calls":RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),"primitives":RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)})
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("main-lawn",Vector3(-190,180,-12),Vector3(20,0,-275))
	await capture("central-court",Vector3(-9,7,-300),Vector3(72,10,-352))
	await capture("library-pool",Vector3(109,5,-361),Vector3(76,16,-291))
	await capture("lower-district",Vector3(-245,220,-490),Vector3(14,0,-780))
	await capture("teaching-row",Vector3(-6,8,-160),Vector3(-55,14,-337))
	await capture("student-approach",Vector3(6,4,-420),Vector3(80,12,-400))
	var report: Dictionary={"captures":captures,"failures":failures,"render_samples":render_samples,"build_ms":world.built_ms,"scope":"Forest canopy and distinct grass/path drawing heights; visual-only geometry, collision and anchors unchanged. Render counters are local frame submission counts, not unique triangles or an FPS claim."}
	FileAccess.open("res://tests/artifacts/lower_campus_integration_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LOWER_INTEGRATION_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
