extends Node
var world: Node3D
var checks:=0
var errors: Array=[]
var episodes: Array=[]
var qa_start:=Time.get_ticks_msec()
func check(value: bool,label: String) -> void:
	checks+=1
	if not value:errors.append(label);push_error("V6 QA: "+label)
func _ready() -> void:run.call_deferred()
func run() -> void:
	if DisplayServer.get_name()!="headless":DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	world.top_down=false;world.update_mode()
	var api: Node=world.agent_environment
	var tasks: Array=JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/campus_tasks_v6.json"))
	var policy:=preload("res://agents/unified/CampusRuleAgent.gd").new()
	check(world.player.get_script().resource_path=="res://player/Player.gd","same original player")
	check(world.used_cache,"exact V5 packed geometry")
	for task: Dictionary in tasks:
		await api.reset(task);policy.reset_episode()
		for i in 20:
			if api.is_done():break
			var action: Dictionary=policy.choose(api.observe(),api.get_available_actions())
			if action.is_empty():break
			var transition: Dictionary=await api.step(action)
			check(transition.valid,"rule action "+task.id+" "+JSON.stringify(action))
			if not transition.valid:break
		var result: Dictionary=api.get_result();check(result.success,"rule task "+task.id)
		episodes.append(result);print("V6_TASK ",task.id," ",result.success," ",api.samples)
		if not errors.is_empty():break
	if errors.is_empty():
		# Fresh physical action replay compares visits, time, distance, verdict.
		await api.reset(tasks[2]);var t: Dictionary=await api.step({"type":"navigate_to","target":tasks[2].goals[0]})
		check(t.valid,"replay recording")
		var record: Dictionary={"task":tasks[2],"trajectory":api.trajectory.duplicate(true),"result":api.get_result()}
		var replay: Dictionary=await preload("res://agents/unified/CampusReplay.gd").replay(api,record)
		check(replay.success,"replay physical equivalence")
		# Stress every public building, including stairs, exit/re-entry and streaming.
		for d: Dictionary in world.interiors.definitions:
			var goals: Array=[d.rooms[-1],d.building_id+"_exit_main",d.rooms[0],d.building_id+"_exit_main"]
			if d.has("upper_slice"):goals.insert(1,d.building_id+"_upper_platform")
			await api.reset({"id":"stress_"+d.building_id,"start":d.building_id,"goals":goals})
			for goal: String in goals:
				var transition: Dictionary=await api.step({"type":"navigate_to","target":goal})
				check(transition.valid,"stress "+d.building_id+" "+goal)
				if not transition.valid:break
			check(api.get_result().success,"bidirectional "+d.building_id);episodes.append(api.get_result())
			if not errors.is_empty():break
	if errors.is_empty():
		# Fifty mixed episodes, each with physical entry and exit; not a reset-only count.
		var random_policy:=preload("res://agents/unified/CampusRandomAgent.gd").new()
		for i in 50:
			var d: Dictionary=world.interiors.definitions[i%10];var goal: String=d.rooms[0]
			await api.reset({"id":"stability_"+str(i),"start":d.building_id,"goals":[goal,d.building_id+"_exit_main"]})
			check(api.trajectory.is_empty() and api.steps==0 and api.failures.is_empty() and not GameState.get_flag("phone_open") and not GameState.get_flag("helped_student"),"reset isolation "+str(i))
			# Random selection is genuinely among currently legal actions, bounded to nearby anchors/time/UI.
			random_policy.reset_episode(i+100)
			var safe: Array=[]
			for a: Dictionary in api.get_available_actions():
				if a.type!="navigate_to" or api.registry.anchor(a.target).distance_to(world.player.global_position)<20:safe.append(a)
			var ra: Dictionary=random_policy.choose(api.observe(),safe)
			var random_result: Dictionary=await api.step(ra);check(random_result.valid,"random legal action "+str(i))
			if GameState.get_flag("phone_open"):await api.step({"type":"close_phone"})
			for id: String in [goal,d.building_id+"_exit_main"]:
				var r: Dictionary=await api.step({"type":"navigate_to","target":id});check(r.valid,"stability physical "+str(i))
			episodes.append(api.get_result())
			if not errors.is_empty():break
		# Mock compatibility validates exact legal member, bad response rejection and clock gating.
		await api.reset(tasks[2]);var available: Array=api.get_available_actions();var before:=WorldTime.current_time
		await api.frames(120)
		check(WorldTime.current_time==before,"decision latency frozen")
		var adapter:=preload("res://agents/unified/CampusLLMAdapter.gd").new()
		var mock:=preload("res://agents/unified/CampusMockProvider.gd").new();add_child(mock);adapter.provider=mock
		var mock_response: Dictionary=await adapter.choose(api.observe(),available)
		check(mock_response.ok and WorldTime.current_time==before,"provider contract and latency gate")
		if mock_response.ok:
			var executed: Dictionary=await api.step(mock_response.value);check(executed.valid,"mock action physical execution")
		check(adapter.validate(JSON.stringify(available[0]),available).ok,"mock provider legal response")
		check(not adapter.validate('{"type":"teleport"}',available).ok,"mock invalid rejected")
		var observation: Dictionary=api.observe()
		check(not observation.has("graph") and not observation.has("verifier") and not observation.has("teacher_state"),"observation leakage audit")
		# Temporary test fixture blocks a real entrance; never saved as campus geometry.
		await api.reset({"id":"blocked_fixture","start":"library","goals":["library_lobby"]})
		var blocker:=StaticBody3D.new();var shape:=CollisionShape3D.new();var box:=BoxShape3D.new();box.size=Vector3(40,12,1);shape.shape=box;blocker.add_child(shape)
		world.add_child(blocker);blocker.position=api.registry.anchor("library_main_entrance")+Vector3(0,5,1.5)
		var blocked: Dictionary=await api.step({"type":"navigate_to","target":"library_lobby"})
		check(not blocked.valid and blocked.reason=="PHYSICS_BLOCKED" and api.samples<3000,"bounded real collision failure without teleport")
		blocker.queue_free();await api.frames(2)
	if "--v6-showcase" in OS.get_cmdline_user_args() and errors.is_empty():await showcase()
	api.finish()
	var report: Dictionary={"checks":checks,"failures":errors.size(),"errors":errors,"episodes":episodes,"wall_ms":Time.get_ticks_msec()-qa_start,"scene":"UnifiedCampus","physics":"original CharacterBody3D","manual_human_testing":false,"teleport_during_navigation":false}
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	FileAccess.open("res://tests/artifacts/v6_qa.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("V6_QA ",checks," / ",errors.size()," episodes ",episodes.size());get_tree().quit(0 if errors.is_empty() else 1)
func showcase() -> void:
	var api: Node=world.agent_environment
	var goals: Array=[]
	for route: Dictionary in JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/campus_showcase_v5.json")):
		var d: Dictionary={}
		for candidate: Dictionary in world.interiors.definitions:
			if candidate.building_id==route.destination:d=candidate
		if d.is_empty():goals.append(route.destination)
		else:
			goals.append(d.rooms[-1])
			if d.has("upper_slice"):goals.append(d.building_id+"_upper_platform")
			goals.append(d.building_id+"_exit_main")
	await api.reset({"id":"full_showcase","name":"全校园连续巡游","start":"upper_central","goals":goals,"deadline_seconds":20000})
	for goal: String in goals:
		var result: Dictionary=await api.step({"type":"navigate_to","target":goal});check(result.valid,"continuous showcase "+goal)
		print("V6_SHOWCASE ",goal," ",result.valid)
		if not result.valid:break
	check(api.get_result().success,"full showcase verdict");episodes.append(api.get_result())
