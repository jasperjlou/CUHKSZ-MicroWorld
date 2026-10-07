extends "res://tests/ExteriorReverseQA.gd"
var reports: Array=[]
var measurements: Array=[]

func walk(points: Array,label: String,interior: bool=false) -> bool:
	for point: Vector3 in points:
		var reached:=false;var stuck:=0
		for i in 6000:
			var direction: Vector3=point-world.player.position;direction.y=0
			if direction.length()<.45:reached=true;break
			direction=direction.normalized();var before: Vector3=world.player.position
			for action: String in ["move_left","move_right","move_forward","move_back"]:Input.action_release(action)
			Input.action_press("move_right" if direction.x>=0 else "move_left",absf(direction.x));Input.action_press("move_back" if direction.z>=0 else "move_forward",absf(direction.z));Input.action_press("jog")
			await get_tree().physics_frame;physical_samples+=1;walking_distance+=before.distance_to(world.player.position)
			stuck=stuck+1 if before.distance_to(world.player.position)<.008 else 0
			if i%60==0:
				var gap: float=world.player.camera.global_position.distance_to(world.player.position);max_camera_gap=maxf(max_camera_gap,gap)
				check(is_finite(gap) and gap>.9 and gap<25,"camera "+label)
				check(is_finite(world.player.position.y),"finite height "+label)
			if stuck>120:
				for c in world.player.get_slide_collision_count():
					var hit: KinematicCollision3D=world.player.get_slide_collision(c);print("V5_BLOCKER ",label," ",world.player.position," ",hit.get_collider().get_path()," ",hit.get_normal())
				break
		for action: String in ["move_left","move_right","move_forward","move_back","jog"]:Input.action_release(action)
		check(reached,"walk waypoint "+label+" "+str(point))
		if not reached:return false
	return true

func stats(label: String) -> void:
	await frames(20);var start:=Time.get_ticks_usec()
	for i in 120:await get_tree().process_frame
	var lights:=0;var meshes:=0;var shapes:=0;var queue: Array[Node]=[world]
	while not queue.is_empty():
		var n: Node=queue.pop_back()
		if n is Light3D:lights+=1
		if n is MeshInstance3D and n.is_visible_in_tree():meshes+=1
		if n is CollisionShape3D and not n.disabled:shapes+=1
		for child: Node in n.get_children():queue.append(child)
	measurements.append({"label":label,"frame_ms":(Time.get_ticks_usec()-start)/120000.0,"draw_calls":RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),"nodes":Performance.get_monitor(Performance.OBJECT_NODE_COUNT),"visible_meshes":meshes,"lights":lights,"shapes":shapes})

func visit(d: Dictionary) -> bool:
	var root: Node3D=world.objects[d.building_id];var cz: float=d.center_local[2];var front: float=cz+d.depth/2
	var points: Array=[root.to_global(Vector3(0,0,front+2)),root.to_global(Vector3(0,0,front-3)),root.to_global(Vector3(0,0,cz)),root.to_global(Vector3(0,0,cz-10))]
	if d.zone_type=="teaching":points.append(root.to_global(Vector3(0,0,cz+1)));points.append(root.to_global(Vector3(-7,0,cz+1)));points.append(root.to_global(Vector3(-7,0,cz-9)))
	var ok:=await walk(points,d.building_id+" inside",true)
	if ok:check(world.interiors.active_id==d.building_id,"interior zone "+d.building_id)
	await capture("V5_"+d.building_id+"_player")
	if ok and d.zone_type in ["library","music","student","college","teaching"]:await stats("V5 active "+d.building_id)
	if ok and d.zone_type=="teaching":ok=await walk([root.to_global(Vector3(-7,0,cz+1)),root.to_global(Vector3(0,0,cz+1))],"classroom exit",true)
	if ok and d.zone_type in ["library","college","teaching","music","admin"]:
		var x: float=d.width/2-4
		ok=await walk([root.to_global(Vector3(0,0,cz+7)),root.to_global(Vector3(x,0,cz+7)),root.to_global(Vector3(x,5,cz-12)),root.to_global(Vector3(0,5,cz-12))],d.building_id+" stair up",true)
		if ok:check(absf(world.player.position.y-root.position.y-5)<.5,"upper landing floor "+d.building_id)
		await capture("V5_"+d.building_id+"_landing")
		if ok:ok=await walk([root.to_global(Vector3(x,5,cz-12)),root.to_global(Vector3(x,0,cz+7)),root.to_global(Vector3(0,0,cz+7))],d.building_id+" stair down",true)
	if ok:ok=await walk([root.to_global(Vector3(0,0,front+4))],d.building_id+" leave",true)
	await frames(20);if ok:check(world.interiors.active_id.is_empty(),"exterior zone after exit "+d.building_id)
	return ok

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	if DisplayServer.get_name()!="headless":DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	await frames(30)
	world.status.visible=false
	var startup:=Time.get_ticks_msec();world.top_down=true;world.update_mode();world.frame(Vector3(450,0,385),1420)
	await stats("V5 exterior overview");await capture("V5_full_campus_aerial")
	check(world.used_cache,"valid V5 baked exterior");check(world.player.get_script().resource_path=="res://player/Player.gd","frozen player controller")
	check(world.interiors.active_id.is_empty(),"outside initial interior zone")
	for id: String in world.interiors.loaded:check(not world.interiors.loaded[id].visible,"far detail hidden "+id)
	for d: Dictionary in world.interiors.definitions:
		var root: Node3D=world.interiors.activate(d)
		world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.global_position=root.to_global(Vector3(0,3.8,d.depth/2-4));world.overview.look_at(root.to_global(Vector3(-3,2,-6)))
		root.visible=true;await capture("V5_"+d.building_id+"_interior")
		var names: Dictionary={"ling":"Ling_lobby","muse":"Muse_lobby","music":"Music_foyer","sports_hall":"Sports_foyer","library":"Library_lobby","student_centre":"StudentCentre_interior","administration":"Admin_lobby","conference":"Conference_foyer","teaching_a":"Teaching_lobby","shaw_east":"Shaw_lobby"}
		await capture("V5_"+names[d.building_id])
		if d.building_id in ["library","teaching_a","ling"]:
			world.overview.global_position=root.to_global(Vector3(-6,3.5,2));world.overview.look_at(root.to_global(Vector3(-7,1.7,-9)))
			await capture("V5_"+({"library":"Library_reading","teaching_a":"Classroom","ling":"HighTable"}[d.building_id]))
		if d.building_id in ["ling","music","library","student_centre"]:
			var building: Node3D=world.objects[d.building_id]
			world.overview.global_position=building.to_global(Vector3(18,12,d.center_local[2]+d.depth/2+35));world.overview.look_at(building.to_global(Vector3(0,5,0)))
			await capture("V5_"+({"ling":"Ling","music":"Music","library":"Library","student_centre":"StudentCentre"}[d.building_id])+"_exterior")
	world.top_down=false;world.update_mode()
	for d: Dictionary in world.interiors.definitions:
		var root: Node3D=world.objects[d.building_id];var p: Vector3=root.to_global(G.vec(d.approach_local));world.player.position=Vector3(p.x,G.height_at(p.x,p.z)+.4,p.z);world.player.velocity=Vector3.ZERO;await frames(90)
		var ok:=await visit(d);reports.append({"id":d.building_id,"success":ok,"spawn_before_route":true,"teleport_during_route":false});print("V5_SIDE ",d.building_id," ",ok)
		if not ok:break

	if "--v5-full" in OS.get_cmdline_user_args() and errors.is_empty():
		world.player.position=G.point("upper_central")+Vector3.UP*.4;world.player.velocity=Vector3.ZERO;await frames(90)
		await walk_corridor();await walk_reverse();await seamless_route()
	if "--v5-events" in OS.get_cmdline_user_args():await event_smoke()
	var report: Dictionary={"startup_ms":startup,"checks":checks,"failures":errors.size(),"errors":errors,"routes":reports,"measurements":measurements,"activation_ms":world.interiors.activation_ms,"physical_samples":physical_samples,"distance_game_units":walking_distance,"max_camera_gap":max_camera_gap,"scripted_input":true,"manual_human_testing":false}
	FileAccess.open("res://tests/artifacts/v5_qa.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"));print("V5_QA ",JSON.stringify(report));get_tree().quit(0 if errors.is_empty() else 1)

func seamless_route() -> void:
	world.top_down=false;world.update_mode();world.player.position=G.point("upper_central")+Vector3.UP*.4;world.player.velocity=Vector3.ZERO;await frames(90)
	var routes: Array=JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/campus_showcase_v5.json"))
	for route: Dictionary in routes:
		var points: Array=[]
		for p: Array in route.points:points.append(G.vec(p))
		var ok:=await walk(points,"seamless "+route.destination)
		for d: Dictionary in world.interiors.definitions:
			if d.building_id==route.destination and ok:ok=await visit(d)
		reports.append({"id":"seamless_"+route.destination,"success":ok,"teleport_during_route":false})
		if not ok:return
	await capture("V5_SeamlessRoute_end")

func event_smoke() -> void:
	GameState.reset();GameState.set_flag("started",true)
	world.top_down=false;world.update_mode()
	var teacher: Node3D=world.event_demo.teacher
	var point: Vector3=teacher.global_position+Vector3(0,0,4)
	world.player.position=Vector3(point.x,G.height_at(point.x,point.z)+.4,point.z);world.player.velocity=Vector3.ZERO;await frames(60)
	Input.action_press("phone");await frames(3);Input.action_release("phone")
	check(GameState.get_flag("phone_open"),"Tab phone state")
	Input.action_press("move_forward");await frames(66);Input.action_release("move_forward")
	check(GameState.get_flag("teacher_warned"),"original teacher first warning")
	Input.action_press("phone");await frames(3);Input.action_release("phone");await frames(40)
	check(not GameState.get_flag("phone_open") and teacher.closed_since_warning,"original close-phone acknowledgement")
	await frames(500)
	Input.action_press("phone");await frames(3);Input.action_release("phone");Input.action_press("move_back");await frames(66);Input.action_release("move_back")
	check(GameState.get_flag("teacher_warned_twice"),"original bounded second teacher warning")
	Input.action_press("phone");await frames(3);Input.action_release("phone")
	var student: Node3D=world.event_demo.student
	point=student.global_position+Vector3(0,0,3)
	world.player.position=Vector3(point.x,G.height_at(point.x,point.z)+.4,point.z);world.player.velocity=Vector3.ZERO;await frames(60)
	student.interact();check(world.event_demo.panel.visible,"reused photo choices visible")
	world.event_demo.choices.get_child(0).pressed.emit();await frames(220)
	check(GameState.get_flag("helped_student") and not GameState.get_flag("busy") and not world.player.photo_mode,"original photo completion and control restoration")
	check(world.event_demo.photo_time_cost==35,"photo time cost retained in isolated demo")
	for type in 4:
		var door:=preload("res://world/campus_seamless/InteriorDoor.gd").new();door.door_type=type;door.position=Vector3(0,500+type*10,0);world.add_child(door)
		door.update(door.global_position,1)
		check(door.open==(type!=3),"door mode "+str(type))
		if type!=0:check(door.leaves[0].get_child(0).collision_layer==(1 if type==3 else 0),"door passage layer "+str(type))
		door.update(door.global_position+Vector3(100,0,100),1)
		check(not door.open,"door leaves close safely "+str(type));door.queue_free()
