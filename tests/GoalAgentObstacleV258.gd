extends "res://tests/GoalAgentV258.gd"
func run()->void:
	var product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(4)
	product.start_goal_agent();await frames(12)
	var a=product.goal_agent;var w=product.world
	a.begin_goal("east_square");check(a.state=="walking","initial path exists")
	if a.state!="walking":quit(1);return
	var point:Vector3=a.registry.graph.get_point_position(a.route[mini(3,a.route.size()-1)])
	var body:=StaticBody3D.new();body.position=point+Vector3.UP*1.5;w.add_child(body)
	var shape:=CollisionShape3D.new();var box:=BoxShape3D.new();box.size=Vector3(3,3,3);shape.shape=box;body.add_child(shape)
	for i in 10000:
		await physics_frame
		if a.replans>0 or a.state in ["failed","complete"]:break
	check(a.replans>0,"new live obstacle triggers physical replan")
	check(a.visited.is_empty(),"blocked task cannot claim observed target")
	var blocked_trace=a.trajectory.duplicate(true)
	a.cancel();body.queue_free();await frames(3)
	a.begin_goal("east_square")
	for i in 16000:
		await physics_frame
		if a.state in ["failed","complete"]:break
	check(a.state=="complete","retry after obstacle removal uses current world")
	FileAccess.open("res://tests/artifacts/goal_agent_obstacle_v258.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"blocked_trace":blocked_trace,"retry_trace":a.trajectory},"\t"))
	print("GOAL_OBSTACLE_V258 ",JSON.stringify(checks));quit(0 if failures.is_empty() else 1)
