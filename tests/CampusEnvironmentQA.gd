extends "res://tests/CampusArchitectureQA.gd"
const Env := preload("res://world/campus_master/environment/CampusEnvironment.gd")
var side_reports: Array=[]

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	if DisplayServer.get_name()!="headless":DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	await frames(10)
	var baseline: bool="--environment-baseline" in OS.get_cmdline_user_args()
	var report: Dictionary={"baseline":baseline,"startup_msec":Time.get_ticks_msec(),"renderer":RenderingServer.get_current_rendering_method()}
	var meshes:=0;var batches:=0;var shapes:=0;var nodes: Array[Node]=[world];var materials: Dictionary={}
	while not nodes.is_empty():
		var node: Node=nodes.pop_back()
		if node is MeshInstance3D:meshes+=1
		if node is MultiMeshInstance3D:batches+=1
		if node is CollisionShape3D:shapes+=1
		if node is GeometryInstance3D and node.material_override!=null:materials[node.material_override.get_instance_id()]=true
		for child: Node in node.get_children():nodes.append(child)
	report.merge({"nodes":int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),"mesh_instances":meshes,"batches":batches,"collision_shapes":shapes,"materials":materials.size()})
	await frames(30);var start:=Time.get_ticks_usec()
	for i in 120:await get_tree().process_frame
	report["measured_frame_ms"]=(Time.get_ticks_usec()-start)/120000.0
	report["draw_calls"]=RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	world.status.visible=false;world.show_labels=false
	var captures: Array=[
		["campus_environment_v3_overview",Vector3(450,0,385),1420.0,false],
		["upper_environment_v3",Vector3(470,54,-90),570.0,true],
		["fairy_lake_environment_v3",Vector3(0,24,55),480.0,true],
		["lower_environment_v3",Vector3(600,8,730),750.0,true]]
	for entry: Array in captures:
		world.frame(entry[1],entry[2],entry[3]);await capture(entry[0]+("_v2_before" if baseline else ""))
	var views: Array=[
		["upper_college_walk_v3","ling",Vector3(18,12,70)],
		["fairy_lake_walk_v3","lake_stone",Vector3(20,8,15)],
		["library_plaza_v3","library",Vector3(35,13,70)],
		["student_centre_v3","student_centre",Vector3(30,10,60)],
		["admin_conference_v3","administration",Vector3(85,15,80)],
		["sports_environment_v3","sports_hall",Vector3(30,13,70)],
		["shaw_environment_v3","shaw_east",Vector3(25,11,60)],
		["shuttle_stop_v3","upper_stop",Vector3(14,8,19)],
		["corridor_v3","ling",Vector3(10,7,53)]]
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE
	for entry: Array in views:
		var root: Node3D=world.objects[entry[1]]
		world.overview.position=root.position+entry[2];world.overview.look_at(root.position+Vector3.UP*3)
		await capture(entry[0]+("_v2_before" if baseline else ""))
	world.overview.projection=Camera3D.PROJECTION_ORTHOGONAL;world.frame(Vector3(450,0,385),1420)
	if not baseline:
		check(world.has_node("CampusEnvironmentV3"),"environment scene loaded")
		check(Env.stats.routes==15 and Env.stats.entrances==44,"all roads, paths and entrances rendered")
		for o: Dictionary in G.master.objects:
			if o.category=="building":check(world.objects[o.id].position.distance_to(G.vec(o.center))<.01,"frozen transform "+o.id)
		for zone: Dictionary in Env.data.zones:
			var node: Node3D=world.get_node("CampusEnvironmentV3/"+zone.id)
			check(node.get_meta("confidence")==zone.confidence and node.get_meta("replaceable"),"zone confidence "+zone.id)
		# New objects cannot obstruct any of the previously clear door volumes.
		for o: Dictionary in G.master.objects:
			if o.category!="building":continue
			var root: Node3D=world.objects[o.id]
			var capsule:=CapsuleShape3D.new();capsule.radius=.57;capsule.height=2.85
			var query:=PhysicsShapeQueryParameters3D.new();query.shape=capsule
			query.transform=Transform3D(Basis.IDENTITY,root.to_global(root.get_meta("entrance_local")+Vector3.UP*1.6));query.exclude=[world.player.get_rid()]
			check(world.get_world_3d().direct_space_state.intersect_shape(query).is_empty(),"door stays clear "+o.id)
		if "--environment-walk" in OS.get_cmdline_user_args():
			world.status.visible=true
			await walk_corridor();await walk_reverse()
			await side_exploration()
		report["environment_statistics"]=Env.stats
	report.merge({"checks":checks,"failures":errors.size(),"errors":errors,"physical_samples":physical_samples,"walking_distance_game_units":walking_distance,"max_camera_body_distance":max_camera_gap,"side_exploration":side_reports,"teleport_during_each_route":false,"evidence":"scripted actual CharacterBody3D input; separate side-route initial spawns, not manual human testing"})
	var filename: String="environment_v2_baseline" if baseline else "environment_v3_walk" if "--environment-walk" in OS.get_cmdline_user_args() else "environment_v3_performance"
	FileAccess.open("res://tests/artifacts/"+filename+".json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ENVIRONMENT_QA ",JSON.stringify(report));get_tree().quit(0 if errors.is_empty() else 1)

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
				check(is_finite(gap) and gap<25,"side camera "+label)
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
		world.player.position=G.vec(route[0])+Vector3.UP*.4;world.player.velocity=Vector3.ZERO;await frames(90)
		var start: Vector3=world.player.position;var ok:=await walk_points(route,id+" arrival")
		if ok and world.objects[id].has_meta("courtyard_local"):
			var p: Vector3=world.objects[id].position
			ok=await walk_points([[p.x,p.y,p.z]],id+" courtyard")
		await capture("environment_side_"+id)
		if ok:
			route.reverse();ok=await walk_points(route,id+" return")
		check(not ok or world.player.position.distance_to(start)<2,"side roundtrip "+id)
		side_reports.append({"id":id,"success":ok,"initial_spawn":true,"teleport_during_route":false});print("ENVIRONMENT_SIDE ",id," ",ok)
	# Full scenic lakeside loop includes west and east, not merely an endpoint query.
	for r: Dictionary in G.paths.paths:
		if r.id!="fairy_lake_scenic":continue
		world.player.position=G.vec(r.geometry[0])+Vector3.UP*.4;world.player.velocity=Vector3.ZERO;await frames(90)
		var ok:=await walk_points(r.geometry,"lake east-west loop")
		side_reports.append({"id":"lake_east_west","success":ok,"initial_spawn":true,"teleport_during_route":false})
		await capture("environment_side_lake_west")
