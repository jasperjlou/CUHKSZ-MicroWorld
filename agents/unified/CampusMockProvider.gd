extends Node
# Local provider contract test. No network, token or model score claims.
func generate_action(context: Dictionary) -> Dictionary:
	await get_tree().process_frame
	var chosen: Dictionary={}
	for a: Dictionary in context.payload.available_actions:
		if a.type=="navigate_to" and a.target==context.payload.observation.current_task.destinations[0]:chosen=a;break
	return {"ok":not chosen.is_empty(),"content":JSON.stringify(chosen),"latency":0,"usage":{},"provider":"local_mock"}
