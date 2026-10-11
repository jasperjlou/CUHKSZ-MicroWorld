extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("bc-v121-b-deck-final",Vector3(-47,8.9,-201),Vector3(-56,7.6,-208))
	var checks: Array=[]
	for row: Array in [
		["outer deck support",Vector3(-47,10,-218),Vector3(-47,6,-218),true],
		["connector support",Vector3(-51,10,-200.56),Vector3(-51,6,-200.56),true],
		["deck inner guard",Vector3(-47,7.7,-218),Vector3(-50,7.7,-218),false],
		["deck outer guard",Vector3(-47,7.7,-218),Vector3(-42,7.7,-218),false]]:
		var hit: Dictionary=world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(row[1],row[2]))
		var valid: bool=not hit.is_empty()
		if valid and row[3]:valid=absf(hit.position.y-7.165)<.06
		checks.append({"name":row[0],"valid":valid})
		if not valid:failures.append(row[0])
	await fixture(Vector3(-55,7.4,-200.56),[
		[Vector3(-47,7.165,-200.56),"through guard opening to outer deck"],
		[Vector3(-47,7.165,-218),"guarded deck passage"],
		[Vector3(-47,7.165,-200.56),"return to connector"],
		[Vector3(-55,7.165,-200.56),"guard opening back to inner gallery"]])
	FileAccess.open("res://tests/artifacts/teaching_bc_v121_deck.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"checks":checks,"failures":failures,"physical_legs":legs,"fixtures":1,"scope":"Inner guard added after initial24legs; four affected deck legs plus support and guard probes. Earlier deck closeup was obstructed and is not accepted."},"\t"))
	quit(0 if failures.is_empty() else 1)
