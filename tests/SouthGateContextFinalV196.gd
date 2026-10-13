extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("south-context-v196-final-gate",Vector3(-179,3.94,-167),Vector3(-265,22,-167))
	await capture("south-context-v196-final-sidewalk",Vector3(-180,3.94,-222),Vector3(-180,3.94,-152))
	FileAccess.open("res://tests/artifacts/south_gate_context_final_v196.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"failures":failures,"trees":world.get_node("SouthGateContextV196").get_meta("forest_tree_count"),"understory_clusters":world.get_node("SouthGateContextV196").get_meta("understory_cluster_count"),"scope":"Understory appearance only;no physics change after8passed local legs"},"\t"))
	quit(0 if failures.is_empty() else 1)
