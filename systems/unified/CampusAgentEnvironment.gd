extends Node
const Registry:=preload("res://systems/unified/CampusRegistry.gd")
const Verifier:=preload("res://systems/unified/CampusVerifier.gd")
const G:=preload("res://world/campus_exterior/ExteriorGeometry.gd")
var world: Node3D
var registry:=Registry.new()
var task: Dictionary={}
var visited: Array=[]
var events: Array=[]
var trajectory: Array=[]
var failures: Array=[]
var steps:=0
var distance:=0.0
var samples:=0
var executing:=false
var generation:=0
var decision_gated:=true
var human_mode:=false
var finished:=false
var replan_count:=0
var stuck_recoveries:=0
var navigation_ms:=0.0
var previous: Vector3
var location_state: Dictionary={}
var tick_count:=0
var occupied: Array=[]
func _ready() -> void:
	EventBus.event_emitted.connect(_on_event)
func _on_event(record: Dictionary) -> void:
	events.append(record.duplicate(true))
func reset(next_task: Dictionary) -> void:
	if not task.is_empty() and steps>0 and not finished:finish()
	generation+=1;executing=false;finished=false;task=next_task.duplicate(true)
	world.player.navigation_direction=Vector2.ZERO;world.player.agent_controlled=not human_mode
	GameState.reset();GameState.set_flag("started",true);WorldTime.configure(18*3600,1,INF);EventBus.reset();EventLogger.prepare_next_run()
	visited.clear();events.clear();trajectory.clear();failures.clear();occupied.clear();steps=0;distance=0;samples=0;replan_count=0;stuck_recoveries=0;tick_count=0;location_state.clear()
	# Only episode setup writes the physical body position. Navigation never does.
	var p:=registry.anchor(task.get("start","upper_central"))
	var record: Dictionary=registry.locations[task.get("start","upper_central")]
	if record.type in ["outdoor","building","exit","interaction"]:p.y=G.height_at(p.x,p.z)
	world.player.global_position=p+Vector3.UP*.3;world.player.velocity=Vector3.ZERO
	previous=world.player.global_position
	world.interiors.active_id="";world.interiors.camera_blend=0;world.player.camera_offset=world.player.CAMERA_OFFSET
	for id: String in world.interiors.loaded:
		var root: Node3D=world.interiors.loaded[id];root.get_parent().remove_child(root);root.free()
	world.interiors.loaded.clear();world.interiors.activation_ms.clear()
	for door: Node3D in world.interiors.doors.values():door.update(door.global_position+Vector3(100,0,100),1)
	world.event_demo.panel.hide();world.event_demo.photo_time_cost=0;world.event_demo.elapsed=0
	world.event_demo.student.photo_remaining=0;world.event_demo.student.invitation_remaining=0;world.event_demo.student.shutter_fired=false
	world.player.end_photo();world.player.phone_mesh.visible=false
	for key: String in ["pending_warning","reaction_remaining","acknowledge_remaining","attention_remaining","bubble_remaining","wave_remaining"]:world.event_demo.teacher.set(key,0)
	world.event_demo.teacher.last_warning_time=-100;world.event_demo.teacher.closed_since_warning=false;world.event_demo.teacher.last_perception=false
	world.event_demo.teacher.bubble.hide();world.event_demo.student.bubble.hide()
	EventLogger.log_directory="user://v6_logs";EventLogger.begin_run()
	await frames(40)
	previous=world.player.global_position
	GameState.set_flag("paused",not human_mode)
	update_semantics()
func frames(count: int) -> void:
	for i in count:await get_tree().physics_frame
func _physics_process(delta: float) -> void:
	if not is_instance_valid(world) or task.is_empty():return
	var p: Vector3=world.player.global_position
	if executing or human_mode:
		WorldTime.tick(delta);distance+=previous.distance_to(p);samples+=1
	previous=p
	tick_count+=1
	if tick_count%6==0:update_semantics()
func update_semantics() -> void:
	var current: Array=[]
	for id: String in registry.locations:
		if world.player.global_position.distance_to(registry.anchor(id))<1.0:
			current.append(id)
			if id not in occupied:
				visited.append(id);EventBus.emit_event("entered_room" if registry.locations[id].type=="room" else "reached_landmark","body",{"location":id})
				if id=="ling_high_table_prototype":GameState.set_flag("reached_high_table",true);GameState.set_value("arrival_time",WorldTime.current_time);EventBus.emit_event("HIGH_TABLE_REACHED")
	occupied=current
	var building: String=world.interiors.active_id
	var floor: String="";var zone: String="";var region: String=""
	if not building.is_empty():
		floor=building+"_floor_"+str(1 if world.player.global_position.y-world.objects[building].global_position.y>3.8 else 0)
		zone=building+"_public"
	var nearby: String=registry.at(world.player.global_position)
	if not nearby.is_empty():
		region=registry.locations[nearby].region
		if visited.is_empty() or visited.back()!=nearby:visited.append(nearby);EventBus.emit_event("reached_landmark","body",{"location":nearby})
	if region.is_empty():
		var p: Vector3=world.player.global_position
		region="upper" if p.z<130 and p.x>220 else "lower" if p.z>510 else "fairy_lake" if p.x<220 and p.z<230 else "middle"
	var next: Dictionary={"region":region,"building":building,"floor":floor,"zone":zone,"location":nearby}
	for key: String in ["region","building","floor","zone"]:
		var old: String=location_state.get(key,"")
		if old!=next[key]:
			if key=="floor":EventBus.emit_event("changed_floor","body",{"from":old,"to":next[key]})
			if not old.is_empty():EventBus.emit_event("left_"+key,"body",{"id":old})
			if not next[key].is_empty():EventBus.emit_event("entered_"+key,"body",{"id":next[key]})
	location_state=next
	for key: String in next:GameState.set_value("current_"+key,next[key])
func observe() -> Dictionary:
	var visible: Array=[];var entrances: Array=[]
	var p: Vector3=world.player.global_position
	for r: Dictionary in registry.locations.values():
		var d:=p.distance_to(registry.anchor(r.id))
		if d>22:continue
		var ray:=PhysicsRayQueryParameters3D.create(p+Vector3.UP*1.5,registry.anchor(r.id)+Vector3.UP*1.5,1)
		if not world.get_world_3d().direct_space_state.intersect_ray(ray).is_empty():continue
		visible.append({"id":r.id,"name":r.display_name_zh,"distance":snappedf(d,.1)})
		if r.type=="entrance":entrances.append(r.id)
	var consequences: Array=[]
	for e: Dictionary in events.slice(maxi(0,events.size()-8)):
		if e.event in ["TEACHER_WARNED_PLAYER","TEACHER_SECOND_WARNING","PHOTO_COMPLETED","PHONE_OPENED","PHONE_CLOSED","reached_landmark"]:consequences.append({"event":e.event,"actor":e.actor})
	return {"schema_version":6,"current_region":location_state.get("region",""),"current_location":location_state.get("location",""),"current_building":location_state.get("building",""),"current_floor":location_state.get("floor",""),"current_interior_zone":location_state.get("zone",""),"nearby_landmarks":visible,"visible_entrances":entrances,"current_time":WorldTime.current_time,"phone_open":GameState.get_flag("phone_open"),"messages":[{"from":"朋友","text":"你到哪了？高桌晚宴快开始了，我在门口等你。","replied":GameState.get_flag("responded_to_friend")}] if GameState.get_flag("phone_open") else [],"event_state":{"photo_completed":GameState.get_flag("helped_student"),"signed_in":GameState.get_flag("high_table_signed_in")},"transport_state":"UNAVAILABLE: visual stop placeholders","public_knowledge":registry.public_catalog(),"current_task":{"id":task.get("id",""),"name":task.get("name",""),"description":task.get("description",""),"destinations":task.get("goals",[])},"recent_events":consequences,"legal_actions":get_available_actions()}
func get_available_actions() -> Array:
	if executing or finished:return []
	var actions: Array=[]
	for id: String in registry.locations:actions.append({"type":"navigate_to","target":id})
	actions.append({"type":"close_phone" if GameState.get_flag("phone_open") else "open_phone"})
	actions.append({"type":"wait","duration":5})
	if GameState.get_flag("phone_open") and not GameState.get_flag("responded_to_friend"):actions.append({"type":"reply"})
	if world.event_demo.student.nearby():actions.append({"type":"interact","target":"photo_student"})
	if world.player.global_position.distance_to(registry.anchor("ling_high_table_prototype"))<3 and not GameState.get_flag("high_table_signed_in"):actions.append({"type":"interact","target":"high_table_sign_in"})
	for id: String in world.interiors.doors:
		if world.player.global_position.distance_to(world.interiors.doors[id].global_position)<9:actions.append({"type":"open_door","target":id})
	return actions
func step(action: Dictionary) -> Dictionary:
	if action not in get_available_actions():return {"valid":false,"reason":"INVALID_TARGET","done":is_done(),"events":[]}
	var observation:=observe();var legal:=get_available_actions();var start:=WorldTime.current_time;var first:=events.size();var token:=generation
	GameState.set_flag("paused",false)
	executing=true;steps+=1;var error:=""
	EventBus.emit_event("AGENT_ACTION","agent",action)
	match action.type:
		"navigate_to":error=await navigate(action.target,token)
		"wait":await frames(300)
		"open_phone","close_phone":GameState.set_flag("phone_open",action.type=="open_phone");EventBus.emit_event("PHONE_OPENED" if action.type=="open_phone" else "PHONE_CLOSED")
		"reply":world.reply_phone()
		"open_door":world.interiors.doors[action.target].update(world.player.global_position,1);EventBus.emit_event("door_opened","body",{"id":action.target})
		"interact":
			if action.target=="photo_student":world.event_demo.student.accept_photo();await frames(220)
			else:world.sign_in_high_table()
	if token!=generation:return {"valid":false,"reason":"RESET_INTERRUPTED","done":false,"events":[]}
	world.player.navigation_direction=Vector2.ZERO;await frames(12);executing=false;GameState.set_flag("paused",not human_mode);update_semantics()
	if not error.is_empty():failures.append(error);EventBus.emit_event("navigation_failed","body",{"code":error})
	var transition: Dictionary={"valid":error.is_empty(),"reason":error,"events":events.slice(first).duplicate(true),"world_time_change":WorldTime.current_time-start,"position":[world.player.global_position.x,world.player.global_position.y,world.player.global_position.z],"location":location_state.duplicate(),"navigation":{"replan_count":replan_count,"stuck_recoveries":stuck_recoveries,"distance":distance,"samples":samples},"done":is_done()}
	trajectory.append({"observation":observation,"legal_actions":legal,"action":action.duplicate(),"transition":transition,"provider_metadata":{"mode":"local","reasoning_recorded":false}})
	return transition
func navigate(id: String,token: int,replan_depth: int=0) -> String:
	var start:=Time.get_ticks_usec();var path:=registry.plan(world.player.global_position,id);navigation_ms+=(Time.get_ticks_usec()-start)/1000.0
	if path.is_empty():return "NO_PATH"
	for point: Vector3 in path:
		var best:=INF;var stalled:=0;var retries:=0;var reached:=false
		for i in 10000:
			if token!=generation:return "RESET_INTERRUPTED"
			var offset: Vector3=point-world.player.global_position
			if Vector2(offset.x,offset.z).length()<.40 and absf(offset.y)<1.0:reached=true;break
			var flat:=Vector2(offset.x,offset.z);world.player.navigation_direction=flat.normalized()
			if flat.length()<best-.03:best=flat.length();stalled=0
			else:stalled+=1
			if stalled>180:
				if retries>=2:
					print("V6_BLOCKED ",id," at ",world.player.global_position," point ",point)
					for c in world.player.get_slide_collision_count():print("V6_HIT ",world.player.get_slide_collision(c).get_collider().get_path())
					if replan_depth<1:
						replan_count+=1;return await navigate(id,token,replan_depth+1)
					return "PHYSICS_BLOCKED"
				retries+=1;replan_count+=1;stuck_recoveries+=1;stalled=0;best=INF
				EventBus.emit_event("navigation_replanned","body",{"attempt":retries})
				var replacement:=registry.plan(world.player.global_position,id)
				if replacement.is_empty():return "NO_PATH"
				world.player.navigation_direction=Vector2(-flat.y,flat.x).normalized();await frames(12)
			await get_tree().physics_frame
		if not reached:return "ACTION_TIMEOUT"
	if world.player.global_position.distance_to(registry.anchor(id))>1.2:return "PHYSICS_BLOCKED"
	if visited.is_empty() or visited.back()!=id:visited.append(id)
	EventBus.emit_event("reached_landmark","body",{"location":id})
	return ""
func is_done() -> bool:
	return finished or Verifier.verify(task,snapshot()).success
func snapshot() -> Dictionary:
	return {"visited":visited,"elapsed":WorldTime.current_time-WorldTime.initial_time,"distance":distance,"steps":steps,"physics_samples":samples,"flags":GameState.snapshot(),"failures":failures}
func get_result() -> Dictionary:
	return Verifier.verify(task,snapshot())
func finish() -> void:
	finished=true;EventLogger.finish_run(get_result())
	DirAccess.make_dir_recursive_absolute("user://v6_trajectories")
	var record: Dictionary={"schema_version":6,"task":task,"trajectory":trajectory,"result":get_result()}
	var path: String="user://v6_trajectories/run_"+str(OS.get_process_id())+"_"+str(EventLogger.run_serial)+".json"
	FileAccess.open(path,FileAccess.WRITE).store_string(JSON.stringify(record,"\t"))
	FileAccess.open("user://v6_trajectories/latest.json",FileAccess.WRITE).store_string(JSON.stringify(record,"\t"))
