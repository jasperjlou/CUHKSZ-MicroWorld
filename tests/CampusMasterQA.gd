extends Node
var world: Node3D
const G := preload("res://world/campus_master/CampusGeometry.gd")
var checks := 0
var errors: Array = []
var physical_samples := 0
var walking_distance := 0.0
var max_camera_gap := 0.0

func _ready() -> void:
	run.call_deferred()

func check(ok: bool,message: String) -> void:
	checks+=1
	if not ok: errors.append(message);push_error(message)

func frames(count: int) -> void:
	for i in range(count): await get_tree().physics_frame

func capture(name: String) -> void:
	if DisplayServer.get_name()=="headless": return
	await frames(3)
	get_tree().paused=true
	await RenderingServer.frame_post_draw
	var error := get_viewport().get_texture().get_image().save_png("res://tests/artifacts/"+name+".png")
	get_tree().paused=false
	check(error==OK,"capture "+name)

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	if DisplayServer.get_name()!="headless": DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	await frames(5)
	await capture("campus_masterplan_pass1" if "--pass1" in OS.get_cmdline_user_args() else "campus_masterplan_pass2")
	if "--pass1" in OS.get_cmdline_user_args():
		print("CAMPUS_MASTER_QA ",checks," checks; ",errors.size()," failures")
		get_tree().quit(0 if errors.is_empty() else 1);return
	check(world.objects.size()==G.master.objects.size()-1,"all building/landmark records instantiated")
	check(world.get_node("Regions").get_child_count()==4,"four region subscenes")
	check(world.overview.far>2000,"whole-campus camera range")
	check(world.player is CharacterBody3D,"shared CharacterBody3D controller")
	check(world.player.get_script().resource_path=="res://player/Player.gd","existing controller reused")
	for o: Dictionary in G.master.objects:
		if o.category=="lake":continue
		check(world.objects[o.id].get_meta("spatial_record").confidence==o.confidence,"record confidence "+o.id)
		check(world.objects[o.id].position.distance_to(G.vec(o.center))<.01,"record placement "+o.id)
	# Key events use the same handler as human mode, with fresh state after each.
	var key := InputEventKey.new();key.keycode=KEY_F2;key.pressed=true
	world._unhandled_input(key)
	check(not world.top_down and world.player.camera.current,"F2 switches to third person")
	world._unhandled_input(key)
	check(world.top_down and world.show_labels and world.overview.current,"F2 restores overview and labels")
	world.show_labels=false
	await capture("campus_masterplan_overview")
	world.show_labels=true
	await capture("campus_masterplan_labels")
	world.show_labels=false
	for entry: Array in [["upper_masterplan",Vector3(470,54,-90),570.0],["fairy_lake_masterplan",Vector3(0,24,55),480.0],["lower_masterplan",Vector3(600,8,730),750.0]]:
		world.frame(entry[1],entry[2],true)
		await capture(entry[0])
	world.frame(Vector3(450,0,385),1420)
	await walk_corridor()
	var report := {"checks":checks,"failures":errors.size(),"errors":errors,"physical_samples":physical_samples,"walking_distance_game_units":walking_distance,"max_camera_body_distance":max_camera_gap,"mode":"rendered_automated_traversal" if DisplayServer.get_name()!="headless" else "headless_physical_traversal","teleport_during_route":false}
	FileAccess.open("res://tests/artifacts/campus_physics_qa.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("CAMPUS_MASTER_QA ",checks," checks; ",errors.size()," failures")
	get_tree().quit(0 if errors.is_empty() else 1)

func walk_corridor() -> void:
	world.top_down=false;world.show_labels=false;world.update_mode()
	world.player.agent_controlled=false
	await frames(8)
	var last: Vector3=world.player.position
	for index in range(G.paths.physical_traversal_points.size()):
		var target := G.vec(G.paths.physical_traversal_points[index])
		var id := "bend_%02d" % index
		for n: Dictionary in G.paths.nodes:
			if Vector2(target.x,target.z).distance_to(Vector2(n.position[0],n.position[2]))<.01:id=n.id
		var reached := false
		var stuck_frames := 0
		for i in range(5000):
			var direction: Vector3=target-world.player.position;direction.y=0
			if direction.length()<1.2: reached=true;break
			direction=direction.normalized()
			# Human-equivalent directional input; existing jog speed, gravity and camera.
			for action: String in ["move_left","move_right","move_forward","move_back"]:Input.action_release(action)
			Input.action_press("move_right" if direction.x>=0 else "move_left",absf(direction.x))
			Input.action_press("move_back" if direction.z>=0 else "move_forward",absf(direction.z))
			Input.action_press("jog")
			await get_tree().physics_frame
			physical_samples+=1
			var distance := last.distance_to(world.player.position);walking_distance+=distance
			if distance<.01:stuck_frames+=1
			else:stuck_frames=0
			last=world.player.position
			if stuck_frames>120:
				var blockers: Array=[]
				for c in range(world.player.get_slide_collision_count()):
					var hit: KinematicCollision3D=world.player.get_slide_collision(c)
					blockers.append({"path":str(hit.get_collider().get_path()),"normal":str(hit.get_normal()),"position":str(hit.get_position())})
				print("MASTERPLAN_BLOCKER ",id," ",world.player.position," ",blockers);break
			if i%60==0:
				check(is_finite(world.player.position.y) and absf(world.player.position.y-G.height_at(world.player.position.x,world.player.position.z))<1.0,"grounded traversal "+id)
				var gap: float=world.player.camera.global_position.distance_to(world.player.position)
				max_camera_gap=maxf(max_camera_gap,gap)
				check(is_finite(gap) and gap<25,"finite bounded camera "+id)
		for action: String in ["move_left","move_right","move_forward","move_back","jog"]:Input.action_release(action)
		check(reached,"physical corridor waypoint "+id)
		print("MASTERPLAN_WAYPOINT ",id," reached=",reached," position=",world.player.position)
		if not reached:break
		if id in ["upper_central","lake_east","lower_central"]:
			await frames(4)
			await capture("campus_walk_"+id)
	check(world.player.position.distance_to(G.point("lower_central"))<2,"Upper to lake to Lower reached without teleport")
