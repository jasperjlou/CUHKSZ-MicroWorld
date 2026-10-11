extends SceneTree
## One milestone capture pass: useful views, one physical route, basic budget.
var world: Node3D
var failures: Array[String]=[]
var captures: Array[String]=[]

func _initialize() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	run.call_deferred()

func frames(count: int) -> void:
	for i in count:await physics_frame

func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(15);await RenderingServer.frame_post_draw
	var filename: String="exterior-polish-"+label+("-before" if "--no-exterior-polish" in OS.get_cmdline_user_args() else "-after")+".png"
	var result:=root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)
	if result!=OK:failures.append("capture "+label)
	captures.append(filename)

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	world=load("res://world/unified/UnifiedCampus.tscn").instantiate();root.add_child(world)
	await frames(5)
	world.mode_panel.hide();world.status.hide();world.agent_status.hide();world.details_button.hide();world.explore_guide.hide();world.explore_guide.set_process(false);world.minimap.hide();world.minimap.set_process(false)
	# Hide the HUD backdrop while capturing architecture rather than UI.
	for child: Node in world.ui.get_children():if child is Panel:child.hide()
	world.top_down=true;world.update_mode();world.status.hide()
	var ling: Vector3=world.objects.ling.global_position
	await capture("ling",ling+Vector3(0,11,77),ling+Vector3(0,25,0))
	var library: Vector3=world.objects.library.global_position
	await capture("library",library+Vector3(95,30,125),library+Vector3(0,18,0))
	var student: Vector3=world.objects.student_centre.global_position
	await capture("courtyard",student+Vector3(85,19,105),student+Vector3(0,12,0))
	var p:=preload("res://world/campus_exterior/ExteriorGeometry.gd").point("upper_central")
	await capture("walkway",p+Vector3(-12,5,28),p+Vector3(35,2,-3))
	var teaching: Vector3=world.objects.teaching_a.global_position
	await capture("teaching",teaching+Vector3(65,16,95),teaching+Vector3(0,10,0))
	var start:=Time.get_ticks_usec()
	for i in 120:await process_frame
	var frame_ms: float=(Time.get_ticks_usec()-start)/120000.0
	var report: Dictionary={"captures":captures,"failures":failures,"render_frame_ms":frame_ms,"draw_calls":RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),"manual_testing":false}
	if is_instance_valid(world.exterior_polish):
		report["detail_statistics"]=world.exterior_polish.stats
		var bodies:=0
		var todo: Array[Node]=[world.exterior_polish]
		while not todo.is_empty():
			var node: Node=todo.pop_back()
			if node is CollisionObject3D:bodies+=1
			for child: Node in node.get_children():todo.append(child)
		report["added_collision_bodies"]=bodies
		if bodies!=0:failures.append("visual pass added collision")
		# One representative real Agent approach/entry checks that visuals did not block it.
		world.top_down=false;world.update_mode()
		await world.agent_environment.reset({"id":"polish_entry_smoke","start":"library","goals":["library_lobby"]})
		var transition: Dictionary=await world.agent_environment.step({"type":"navigate_to","target":"library_lobby"})
		report["library_entry_valid"]=transition.valid
		if not transition.valid:failures.append("library approach")
	var filename:="exterior_polish_"+("before" if "--no-exterior-polish" in OS.get_cmdline_user_args() else "after")+".json"
	FileAccess.open("res://tests/artifacts/"+filename,FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("EXTERIOR_POLISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
