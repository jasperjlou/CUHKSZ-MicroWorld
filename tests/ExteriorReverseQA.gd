extends "res://tests/ExteriorRouteQA.gd"

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	if DisplayServer.get_name()!="headless":DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	await frames(10)
	var baseline := "--architecture-baseline" in OS.get_cmdline_user_args()
	var report := {"baseline":baseline,"startup_msec":Time.get_ticks_msec(),"renderer":RenderingServer.get_current_rendering_method()}
	var meshes := 0;var batches := 0;var shapes := 0;var nodes: Array[Node]=[world];var materials: Dictionary={}
	while not nodes.is_empty():
		var node: Node=nodes.pop_back()
		if node is MeshInstance3D:meshes+=1
		if node is MultiMeshInstance3D:batches+=1
		if node is CollisionShape3D:shapes+=1
		if node is GeometryInstance3D and node.material_override!=null:materials[node.material_override.get_instance_id()]=true
		for child: Node in node.get_children():nodes.append(child)
	report["nodes"]=int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT));report["mesh_instances"]=meshes;report["facade_batches"]=batches;report["collision_shapes"]=shapes
	await frames(30)
	var start := Time.get_ticks_usec()
	for i in 120:await get_tree().process_frame
	report["measured_frame_ms"]=(Time.get_ticks_usec()-start)/120000.0
	report["draw_calls"]=RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	report["material_count"]=materials.size()
	if baseline:
		FileAccess.open("res://tests/artifacts/architecture_baseline.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
		await capture("architecture_baseline");get_tree().quit();return
	world.status.visible=false
	world.show_labels=false;await capture("campus_architecture_v2_overview")
	world.show_labels=true;await capture("campus_architecture_v2_labels");world.show_labels=false
	for entry: Array in [["upper_architecture_v2",Vector3(470,54,-90),570.0],["fairy_lake_v2",Vector3(0,24,55),480.0],["lower_architecture_v2",Vector3(600,8,730),750.0]]:
		world.frame(entry[1],entry[2],true);await capture(entry[0])
	var landmarks := {"library":"library","admin":"administration","student_centre":"student_centre","ling":"ling","shaw":"shaw_east","music":"music","sports":"sports_hall"}
	for label: String in landmarks:
		var root: Node3D=world.objects[landmarks[label]]
		var record: Dictionary=root.get_meta("spatial_record")
		var width: float=maxf(record.footprint_width,record.footprint_depth)
		world.frame(root.position,width*1.8,true);await capture(label+"_v2")
		if label=="library":
			world.frame(root.position,width*1.5);await capture("library_v2_aerial")
			world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE
			world.overview.position=root.position+Vector3(0,13,width*.9);world.overview.look_at(root.position+Vector3.UP*9)
			await capture("library_v2_front")
			world.overview.position=root.position+Vector3(width*.65,18,width*.8);world.overview.look_at(root.position+Vector3.UP*9)
			await capture("library_v2_pedestrian");world.overview.projection=Camera3D.PROJECTION_ORTHOGONAL
	for o: Dictionary in G.master.objects:
		if o.category!="building":continue
		var root: Node3D=world.objects[o.id]
		check(root.has_meta("architecture_profile"),"architecture profile "+o.id)
		check(root.position.distance_to(G.vec(o.center))<.01,"frozen building transform "+o.id)
		# Capsule-space clearance across the entrance; controller-height probe, no visual-mesh collision.
		var capsule := CapsuleShape3D.new();capsule.radius=.57;capsule.height=2.85
		for offset in [-1.0,0.0,1.0]:
			var query := PhysicsShapeQueryParameters3D.new();query.shape=capsule
			var entry: Vector3=root.get_meta("entrance_local")+Vector3(0,1.6,offset)
			query.transform=Transform3D(Basis.IDENTITY,root.to_global(entry));query.exclude=[world.player.get_rid()]
			var hits := world.get_world_3d().direct_space_state.intersect_shape(query)
			check(hits.is_empty(),"entrance capsule clearance "+o.id+" / "+str(offset))
		if root.get_meta("architecture_profile").tier=="A":
			world.frame(root.position,maxf(o.footprint_width,o.footprint_depth)*1.8,true)
			await capture(o.id+"_architecture_review")
	# Neutral material check: recognizable forms must not depend on college accent colors.
	var original: Dictionary={};var neutral:=StandardMaterial3D.new();neutral.albedo_color=Color("bdc0b8")
	for root: Node3D in world.objects.values():
		if not root.has_meta("architecture_profile"):continue
		for child: Node in root.get_children():
			if child is GeometryInstance3D and not child is Label3D:
				original[child]=child.material_override;child.material_override=neutral
	world.frame(Vector3(600,8,730),750,true);await capture("architecture_neutral_silhouettes")
	for child: GeometryInstance3D in original:child.material_override=original[child]
	world.status.visible=true
	world.frame(Vector3(450,0,385),1420)
	if "--architecture-walk" in OS.get_cmdline_user_args():
		await walk_corridor()
		await walk_reverse()
	report.merge({"checks":checks,"failures":errors.size(),"errors":errors,"physical_samples":physical_samples,"walking_distance_game_units":walking_distance,"max_camera_body_distance":max_camera_gap,"teleport_during_route":false,"evidence":"scripted existing-controller traversal, not manual human playtest"})
	FileAccess.open("res://tests/artifacts/architecture_v2_walk.json" if "--architecture-walk" in OS.get_cmdline_user_args() else "res://tests/artifacts/architecture_v2_qa.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ARCHITECTURE_QA ",JSON.stringify(report))
	get_tree().quit(0 if errors.is_empty() else 1)

func walk_reverse() -> void:
	var points: Array=G.paths.physical_traversal_points.duplicate();points.reverse()
	for point: Array in points:
		var target := G.vec(point);var reached := false;var stuck := 0
		for i in 5000:
			var direction: Vector3 = target-world.player.position;direction.y=0
			if direction.length()<1.2:reached=true;break
			direction=direction.normalized()
			var before: Vector3=world.player.position
			for action: String in ["move_left","move_right","move_forward","move_back"]:Input.action_release(action)
			Input.action_press("move_right" if direction.x>=0 else "move_left",absf(direction.x))
			Input.action_press("move_back" if direction.z>=0 else "move_forward",absf(direction.z));Input.action_press("jog")
			await get_tree().physics_frame
			physical_samples+=1;walking_distance+=before.distance_to(world.player.position)
			stuck=stuck+1 if before.distance_to(world.player.position)<.01 else 0
			if stuck>120:break
			if i%60==0:
				check(absf(world.player.position.y-G.height_at(world.player.position.x,world.player.position.z))<1,"reverse grounded")
				check(world.player.camera.global_position.distance_to(world.player.position)<25,"reverse camera")
		for action: String in ["move_left","move_right","move_forward","move_back","jog"]:Input.action_release(action)
		check(reached,"reverse corridor "+str(point));print("ARCHITECTURE_REVERSE ",point," reached=",reached)
		if not reached:break
	check(world.player.position.distance_to(G.point("upper_central"))<2,"Lower to lake to Upper without teleport")
