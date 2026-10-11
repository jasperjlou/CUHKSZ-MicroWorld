extends "res://tests/VisualCampusCapture.gd"
var render_samples: Array=[]

func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(18);await RenderingServer.frame_post_draw
	var filename:="landscape-finish-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)
	var start:=Time.get_ticks_usec()
	for i in 45:await RenderingServer.frame_post_draw
	var ms: float=(Time.get_ticks_usec()-start)/45000.0
	render_samples.append({"view":label,"observed_render_frame_ms":ms,"draw_calls":RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),"primitives":RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)})

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("south-gate",Vector3(-181,5.7,-146),Vector3(-152,3.4,-169))
	await capture("avenue",Vector3(-142,5.6,-167),Vector3(-45,5,-167))
	await capture("pond",Vector3(61,5.2,-353),Vector3(88,13,-324))
	await capture("library-roof",Vector3(129,57,-363),Vector3(80,16,-292))
	await capture("teaching-a",Vector3(-7,12,-85),Vector3(-65,13,-115))
	await capture("lobby",Vector3(-43,4,-207),Vector3(-49,4,-207))
	await capture("district",Vector3(-25,38,-308),Vector3(40,5,-359))
	var report: Dictionary={"captures":captures,"failures":failures,"render_samples":render_samples,"sample_frames":45,"build_ms":world.built_ms,"renderer":"OpenGL Compatibility, 1440x900, fixed simulation delta; observed frame timings are local samples, not a gameplay FPS guarantee","scope":"vegetation geometry, shading and non-colliding backdrop; existing route collision was not changed"}
	FileAccess.open("res://tests/artifacts/landscape_visual_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LANDSCAPE_VISUAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
