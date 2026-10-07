extends "res://tests/ExteriorReverseQA.gd"
const Env := preload("res://world/campus_exterior/ExteriorEnvironment.gd")
var side_reports: Array=[]

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	if DisplayServer.get_name()!="headless":DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	await frames(10)
	var report: Dictionary={"startup_msec":Time.get_ticks_msec(),"used_cache":world.used_cache}
	var nodes: Array[Node]=[world];var shapes:=0;var meshes:=0;var batches:=0
	while not nodes.is_empty():
		var node: Node=nodes.pop_back()
		if node is CollisionShape3D:shapes+=1
		if node is MeshInstance3D:meshes+=1
		if node is MultiMeshInstance3D:batches+=1
		for child: Node in node.get_children():nodes.append(child)
	report.merge({"nodes":int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),"collision_shapes":shapes,"mesh_instances":meshes,"batches":batches})
	await frames(30);var start:=Time.get_ticks_usec()
	for i in 120:await get_tree().process_frame
	report["frame_ms"]=(Time.get_ticks_usec()-start)/120000.0
	report["draw_calls"]=RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	check(shapes<1400,"controlled collision budget")
	check(world.player.get_script().resource_path=="res://player/Player.gd","unchanged real controller")
	for o: Dictionary in G.master.objects:
		if o.category!="building":continue
		check(world.objects[o.id].position.distance_to(G.vec(o.center))<.01,"frozen building anchor "+o.id)
		check(world.objects[o.id].has_meta("entrance_local"),"building entrance "+o.id)
		var root: Node3D=world.objects[o.id]
		var shape:=CapsuleShape3D.new();shape.radius=.57;shape.height=2.85
		for offset in [-1.0,0.0,1.0]:
			var query:=PhysicsShapeQueryParameters3D.new();query.shape=shape;query.exclude=[world.player.get_rid()]
			query.transform=Transform3D(Basis.IDENTITY,root.to_global(root.get_meta("entrance_local")+Vector3(0,1.6,offset)))
			var hits:=world.get_world_3d().direct_space_state.intersect_shape(query)
			if not hits.is_empty():print("ENTRANCE_PROBE ",o.id," ",hits)
			check(hits.is_empty(),"entrance clearance "+o.id+" / "+str(offset))
	check(world.objects.music.get_meta("principal_music_masses")==5,"five Music plus two Eighth masses")
	check(world.objects.eighth.get_meta("tower_count")==2,"two Eighth dormitories")
	check(world.objects.muse.get_meta("tower_count")==3 and world.objects.diligentia.get_meta("tower_count")==3,"supported three-dormitory colleges")
	check(not world.accuracy_heatmap.visible,"heatmap hidden by default")
	if DisplayServer.get_name()!="headless":
		var queue: Array[Node]=[world];var live_batches:=0
		while not queue.is_empty():
			var node: Node=queue.pop_back()
			if node is MultiMeshInstance3D and not node.multimesh.buffer.is_empty():
				var populated:=false
				for v in node.multimesh.buffer:
					if absf(v)>.001:populated=true;break
				check(populated,"nonempty baked instance transforms");live_batches+=1
			for child: Node in node.get_children():queue.append(child)
		check(live_batches>200,"rendered instance buffer coverage")
	world.status.visible=false;world.show_labels=false;world.top_down=true;world.update_mode()
	for entry: Array in [["V4_full_campus_aerial",Vector3(450,0,385),1420.0,false],["V4_upper_overview",Vector3(470,54,-90),570.0,true],["V4_fairy_lake_aerial",Vector3(0,24,55),480.0,true],["V4_lower_overview",Vector3(600,8,730),750.0,true]]:
		world.overview.projection=Camera3D.PROJECTION_ORTHOGONAL;world.frame(entry[1],entry[2],entry[3]);await capture(entry[0])
	for entry: Array in [["V4_upper_ground","ling",Vector3(18,8,65)],["V4_college_cluster","muse",Vector3(40,24,75)],["V4_upper_to_middle","harmonia",Vector3(-65,15,80)],["V4_fairy_lake_ground","lake_stone",Vector3(18,6,14)],["V4_music","music",Vector3(55,32,95)],["V4_middle_to_lower","research",Vector3(40,12,55)],["V4_library","library",Vector3(35,12,70)],["V4_student_centre","student_centre",Vector3(30,9,60)],["V4_admin_conference","administration",Vector3(85,14,80)],["V4_shaw","shaw_east",Vector3(25,10,60)],["V4_sports","sports_hall",Vector3(0,8,48)],["V4_corridor","ling",Vector3(10,6,53)],["V4_shuttle_stop","upper_stop",Vector3(14,8,19)],["V4_distant_mountain_context","lake_pavilion",Vector3(25,10,25)]]:
		world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE
		var root: Node3D=world.objects[entry[1]];world.overview.position=root.position+entry[2];world.overview.look_at(root.position+Vector3.UP*3);await capture(entry[0])
	if "--v4-review" in OS.get_cmdline_user_args():
		for o: Dictionary in G.master.objects:
			if o.category!="building":continue
			var root: Node3D=world.objects[o.id];var distance: float=maxf(o.footprint_width,o.footprint_depth)
			world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE
			world.overview.position=root.position+Vector3(-distance*.9,o.estimated_height+distance*.55,-distance*1.1)
			world.overview.look_at(root.position+Vector3.UP*(o.estimated_height*.4));await capture("V4_rear_"+o.id)
		world.overview.projection=Camera3D.PROJECTION_ORTHOGONAL;world.frame(Vector3(450,0,385),1420)
		world.accuracy_heatmap.visible=true;await capture("V4_accuracy_heatmap");world.accuracy_heatmap.visible=false
	world.status.visible=true
	if "--v4-walk" in OS.get_cmdline_user_args():
		await walk_corridor();await walk_reverse();await side_exploration()
		await showcase()
		await capture("V4_full_route_end")
	report.merge({"checks":checks,"failures":errors.size(),"errors":errors,"physical_samples":physical_samples,"distance":walking_distance,"max_camera_gap":max_camera_gap,"side_routes":side_reports,"scripted_input":true,"teleport_during_each_route":false})
	var name: String="v4_walk" if "--v4-walk" in OS.get_cmdline_user_args() else "v4_authoring" if not world.used_cache else "v4_cached"
	FileAccess.open("res://tests/artifacts/"+name+".json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("V4_QA ",JSON.stringify(report));get_tree().quit(0 if errors.is_empty() else 1)

func showcase() -> void:
	var routes: Array=JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/campus_showcase_v4.json"))
	# One independent start, then physically visit the entire sequence without resets.
	world.player.position=G.point("upper_central")+Vector3.UP*.4;world.player.velocity=Vector3.ZERO;await frames(90)
	for route: Dictionary in routes:
		var ok:=await walk_points(route.points,"showcase "+route.destination)
		side_reports.append({"id":"showcase_"+route.destination,"success":ok,"teleport_during_route":false})
		await capture("V4_showcase_"+route.destination)
		if not ok:break

func walk_points(points: Array,label: String) -> bool:
	for point: Array in points:
		var target:=G.vec(point);var reached:=false;var stuck:=0
		for i in 6000:
			var direction: Vector3=target-world.player.position;direction.y=0
			if direction.length()<.8:reached=true;break
			direction=direction.normalized();var before: Vector3=world.player.position
			for action: String in ["move_left","move_right","move_forward","move_back"]:Input.action_release(action)
			Input.action_press("move_right" if direction.x>=0 else "move_left",absf(direction.x))
			Input.action_press("move_back" if direction.z>=0 else "move_forward",absf(direction.z));Input.action_press("jog")
			await get_tree().physics_frame;physical_samples+=1;walking_distance+=before.distance_to(world.player.position)
			stuck=stuck+1 if before.distance_to(world.player.position)<.01 else 0
			if i%60==0:
				var gap: float=world.player.camera.global_position.distance_to(world.player.position);max_camera_gap=maxf(max_camera_gap,gap)
				check(is_finite(gap) and gap>2 and gap<25,"side camera "+label)
				check(absf(world.player.position.y-G.height_at(world.player.position.x,world.player.position.z))<1,"side grounded "+label)
			if stuck>120:
				for c in world.player.get_slide_collision_count():
					var hit: KinematicCollision3D=world.player.get_slide_collision(c)
					print("ENVIRONMENT_BLOCKER ",label," ",world.player.position," ",hit.get_collider().get_path()," ",hit.get_normal())
				break
		for action: String in ["move_left","move_right","move_forward","move_back","jog"]:Input.action_release(action)
		check(reached,"side waypoint "+label+" "+str(point))
		if not reached:return false
	return true

func side_exploration() -> void:
	world.top_down=false;world.show_labels=false;world.update_mode();world.player.agent_controlled=false
	for id: String in ["ling","amenity","music","library","student_centre","administration","conference","teaching_a","shaw_east","sports_hall"]:
		var record: Dictionary={}
		for r: Dictionary in Env.data.entrance_connections:
			if r.building_id==id:record=r;break
		var route: Array=record.geometry.duplicate(true);route.reverse()
		# Independent route initialisation, before walking; no mid-route teleport.
		world.player.position=Vector3(float(route[0][0]),G.height_at(float(route[0][0]),float(route[0][2]))+.4,float(route[0][2]));world.player.velocity=Vector3.ZERO;await frames(90)
		var start: Vector3=world.player.position;var ok:=await walk_points(route,id+" arrival")
		if ok and world.objects[id].has_meta("courtyard_local"):
			var p: Vector3=world.objects[id].position
			ok=await walk_points([[p.x,p.y,p.z]],id+" courtyard")
		await capture("environment_side_"+id)
		if ok:
			route.reverse();ok=await walk_points(route,id+" return")
		check(not ok or world.player.position.distance_to(start)<2,"side roundtrip "+id)
		side_reports.append({"id":id,"success":ok,"initial_spawn":true,"teleport_during_route":false});print("ENVIRONMENT_SIDE ",id," ",ok)
	for r: Dictionary in Env.data.landmark_connections+Env.data.stop_connections:
		var route: Array=r.geometry.duplicate(true);route.reverse()
		world.player.position=Vector3(float(route[0][0]),G.height_at(float(route[0][0]),float(route[0][2]))+.4,float(route[0][2]));world.player.velocity=Vector3.ZERO;await frames(90)
		var destination: String=r.get("landmark_id",r.get("stop_id",""))
		var ok:=await walk_points(route,r.id);await capture("environment_side_"+destination)
		if ok:route.reverse();ok=await walk_points(route,r.id+" return")
		side_reports.append({"id":destination,"success":ok,"initial_spawn":true,"teleport_during_route":false})
	# Full scenic lakeside loop includes west and east, not merely an endpoint query.
	for r: Dictionary in G.paths.paths:
		if r.id!="fairy_lake_scenic":continue
		world.player.position=G.vec(r.geometry[0])+Vector3.UP*.4;world.player.velocity=Vector3.ZERO;await frames(90)
		var route: Array=r.geometry.duplicate(true)
		for main: Dictionary in G.paths.paths:
			if main.id=="fairy_lake_main":route.append_array(main.geometry.slice(1))
		var ok:=await walk_points(route,"lake east-west loop")
		side_reports.append({"id":"lake_east_west","success":ok,"initial_spawn":true,"teleport_during_route":false})
		await capture("environment_side_lake_west")
