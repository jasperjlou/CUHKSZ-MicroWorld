extends "res://tests/GoalAgentV258.gd"
var images:Array=[]
func shot(name:String)->void:
	await process_frame;await RenderingServer.frame_post_draw
	var file:="goal-agent-v258-"+name+".png";root.get_texture().get_image().save_png("res://tests/artifacts/"+file);images.append(file)
func run()->void:
	var product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(4)
	product.agent_button.pressed.emit();await frames(12)
	var a=product.goal_agent
	check(product.mode=="agent","menu button opens goal selector")
	await shot("selector")
	for i in a.chooser.item_count:
		if a.chooser.get_item_metadata(i)=="east_square":a.chooser.select(i)
	a.begin_selected();await frames(180);a.toggle_pause();await frames(5)
	check(a.paused,"UI selected task and paused movement")
	await shot("walking-paused")
	product.start_showcase();await frames(10);check(product.director.running and not a.active,"legacy architectural tour remains optional")
	product.show_menu();await frames(4)
	FileAccess.open("res://tests/artifacts/goal_agent_views_v258.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"images":images,"goal_count":a.chooser.item_count},"\t"))
	print("GOAL_VIEWS_V258 ",JSON.stringify(checks));quit(0 if failures.is_empty() else 1)
