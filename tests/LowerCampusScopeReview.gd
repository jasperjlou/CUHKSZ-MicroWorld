extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="scope-review-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	for r: Dictionary in world.data.buildings:
		if r.id=="gate_north":continue # Both gate wings are visible in the combined view.
		if r.id=="gate_south":
			await capture("east-gate",Vector3(0,13,72),Vector3(0,12,-16));continue
		var fixed: Dictionary={
			"lee_yin_yee":[Vector3(-177,26,-492),Vector3(-120,12,-530)],
			"cheng_dao":[Vector3(0,18,-605),Vector3(-32,10,-646)],
			"le_tian":[Vector3(-1,18,-606),Vector3(46,12,-652)],
			"track":[Vector3(-140,75,-1120),Vector3(-14,2,-1018)]}
		if fixed.has(r.id):
			await capture(r.id,fixed[r.id][0],fixed[r.id][1]);continue
		var p: Vector3=world.builder.point(r.position);var w: float=r.width;var d: float=r.depth;var h: float=r.floor_levels[-1]
		var basis:=Basis(Vector3.UP,deg_to_rad(r.yaw))
		var eye: Vector3=p+basis*Vector3(w*.58,maxf(12,h*.78),(w+d)*.82)
		await capture(r.id,eye,p+Vector3(0,h*.36,0))
	await capture("library-ground",Vector3(85,4.1,-279),Vector3(93,4,-297))
	await capture("library-stair",Vector3(64,4.2,-295),Vector3(80,7.5,-281))
	await capture("administration-entry",Vector3(43,4,-149.93),Vector3(60,4,-149.93))
	await capture("teaching-arcade",Vector3(-47,4.1,-99),Vector3(-50,6.3,-128))
	await capture("courtyard-lower",Vector3(37,.15,-349),Vector3(47,.1,-370))
	await capture("central-enclosure",Vector3(-15,38,-360),Vector3(49,4,-360))
	var report: Dictionary={"captures":captures,"failures":failures,"build_ms":world.built_ms,"version":world.data.version,"records":world.data.buildings.size(),"scope":"Full 24-record visual inventory and six key close views. Visual review only; existing relevant movement reports reused, not rerun."}
	FileAccess.open("res://tests/artifacts/lower_campus_scope_review.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LOWER_SCOPE_REVIEW ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
