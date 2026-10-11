extends "res://tests/LibraryLowerLevelCapture.gd"
func ray(a: Vector3,b: Vector3) -> Dictionary:
	return world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(a,b))
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-atrium-final-v46",wp(9,10.6,10),wp(-12,16,1))
	await capture("library-atrium-gallery-final-v46",wp(12,18.5,14),wp(-13,13,0))
	await capture("library-atrium-skylight-final-v46",wp(-6,10.6,10),wp(-4,24.5,-1))
	await capture("library-fourth-reading-final-v46",wp(36,14.5,2),wp(23,14,-13))
	await capture("library-roof-final-v46",wp(-8,40,54),wp(0,18,2))
	await fixture(wp(-22,17.1,9.4),[
		[wp(-20,16.8,9.4),"left fifth core outer approach"],
		[wp(-20,16.8,12.9),"left core around book wall end"],
		[wp(-16,16.8,12.9),"left core to fifth balcony"],
		[wp(0,16.8,13.4),"fifth continuous front gallery"],
		[wp(5,16.8,13.4),"front gallery toward diagonal core"],
		[wp(-4.444,16.8,16.07),"diagonal fifth core approach"],
		[wp(-7.626,16.8,19.252),"diagonal fifth core doorway"]])
	var guards: Array=[]
	for y in [12.8,16.8]:
		for side in [-1,1]:
			var x: float=-16 if side<0 else 13
			var hit:=not ray(wp(x+side*1.2,y+.65,4),wp(x-side*1.2,y+.65,4)).is_empty()
			guards.append({"level_y":y,"side":side,"hit":hit});if not hit:failures.append("atrium gallery guard")
	var clear:=ray(wp(0,9.2,4),wp(0,21.4,4)).is_empty()
	if not clear:failures.append("atrium vertical opening unexpectedly capped")
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"guards":guards,"vertical_atrium_clear":clear,"build_ms":world.built_ms,"scope":"Final inner-wall, carpet, round-column and diffuser visuals; new 5F core-to-gallery interface and guard samples. Original 54 upper ascent/descent legs retained; tested collision footprints unchanged."}
	FileAccess.open("res://tests/artifacts/library_atrium_finish_v46.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_ATRIUM_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
