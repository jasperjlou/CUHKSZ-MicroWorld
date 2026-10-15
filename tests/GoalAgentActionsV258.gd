extends "res://tests/GoalAgentV258.gd"
func run()->void:
	var product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(4)
	product.start_goal_agent();await frames(15)
	var a=product.goal_agent;var w=product.world
	check(not a.step({"type":"interact","target":"photo_student"}).accepted,"unimplemented NPC action rejected")
	check(not a.step({"type":"observe","target":"space_library-lower"}).accepted,"remote completion rejected")
	a.begin_goal("space_library-lower")
	var previous:Vector3=w.player.global_position;var max_step:=0.0
	for i in 60000:
		await physics_frame;max_step=maxf(max_step,previous.distance_to(w.player.global_position));previous=w.player.global_position
		if a.state in ["complete","failed"]:break
	check(a.state=="complete","East Gate to library lower public space by physics")
	check(max_step<.8,"long route no teleport")
	var library=a.trajectory.duplicate(true)
	# A deliberately disconnected knowledge target must fail without success or relocation.
	var before:Vector3=w.player.global_position
	var unreachable:int=a.registry.add(Vector3(900,400,900))
	a.registry.goals["qa_unreachable"]={"id":"qa_unreachable","name":"QA unreachable","node":unreachable,"position":Vector3(900,400,900)}
	a.begin_goal("qa_unreachable");await frames(3)
	check(a.state=="failed" and a.visited.is_empty(),"unreachable target explicit failure")
	check(w.player.global_position.distance_to(before)<.2,"failure does not teleport")
	a.registry.goals.erase("qa_unreachable")
	# Continue from actual location; nearby targets are chosen by the policy.
	a.begin_goal("space_library-lower",true)
	for i in 60000:
		await physics_frame
		if a.state in ["complete","failed"]:break
	check(a.state=="complete" and a.visited.size()==3,"three-location exploration completes")
	FileAccess.open("res://tests/artifacts/goal_agent_actions_v258.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"library":library,"exploration":a.trajectory,"max_step":max_step,"rejected_edges":a.registry.rejected},"\t"))
	print("GOAL_ACTIONS_V258 ",JSON.stringify(checks));quit(0 if failures.is_empty() else 1)
