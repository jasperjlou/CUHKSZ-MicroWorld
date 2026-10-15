extends SceneTree
var failures:Array=[]
var checks:Array=[]
func check(value:bool,label:String)->void:
	checks.append({"label":label,"valid":value})
	if not value:failures.append(label)
func _initialize()->void:run.call_deferred()
func frames(n:int)->void:
	for i in n:await physics_frame
func run()->void:
	var product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(4)
	product.start_goal_agent();await frames(12)
	var agent=product.goal_agent;var world=product.world
	check(product.mode=="agent","second mode is goal agent")
	check(agent.chooser.item_count>30,"selectable outdoor and interior goals")
	check(not agent.begin_goal("not_a_place"),"invalid goal rejected")
	var start:Vector3=world.player.global_position
	check(agent.begin_goal("east_square"),"select square")
	var maximum_step:=0.0;var previous:Vector3=world.player.global_position
	for i in 16000:
		await physics_frame
		maximum_step=maxf(maximum_step,previous.distance_to(world.player.global_position));previous=world.player.global_position
		if agent.state in ["complete","failed"]:break
	check(agent.state=="complete","physically reach and observe square")
	check(maximum_step<.8,"no teleport during task")
	check(world.player.global_position.distance_to(start)>20,"body actually travelled")
	var first=agent.trajectory.duplicate(true)
	check(agent.begin_goal("central_east"),"retarget central square")
	await frames(30);agent.toggle_pause();await frames(2)
	var pause_at:Vector3=world.player.global_position;await frames(40)
	check(world.player.global_position.distance_to(pause_at)<.06,"pause stops locomotion")
	agent.toggle_pause()
	for i in 22000:
		await physics_frame
		if agent.state in ["complete","failed"]:break
	check(agent.state=="complete","resume and reach central square")
	var second=agent.trajectory.duplicate(true)
	agent.begin_goal("east_gate");await frames(20);agent.cancel();await frames(2)
	var stopped:Vector3=world.player.global_position;await frames(30)
	check(world.player.global_position.distance_to(stopped)<.06 and agent.state=="idle","cancel keeps current position")
	product.show_menu();check(not agent.active,"menu stops agent")
	product.start_player();check(not world.player.agent_controlled,"human mode restores manual control")
	FileAccess.open("res://tests/artifacts/goal_agent_v258.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"square":first,"central":second,"max_step":maximum_step,"rejected_edges":agent.registry.rejected},"\t"))
	print("GOAL_AGENT_V258 ",JSON.stringify(checks));quit(0 if failures.is_empty() else 1)
