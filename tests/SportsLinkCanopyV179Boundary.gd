extends "res://tests/SportsLinkCanopyV179.gd"
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.player.set_physics_process(false)
	var checks:Array=[]
	# The earlier 1.5m ray was above this 0.28m plinth. No scene geometry has changed.
	probe(cp179(14,.20,-1.8),cp179(18,.20,-1.8),true,"retained low Hall plinth",checks)
	FileAccess.open("res://tests/artifacts/sports_link_canopy_v179_boundary.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"physical_walks":0,"scope":"Correct only the rejected plinth ray height; retain both physical batches and final visual review."},"\t"))
	print("CANOPY_V179_BOUNDARY ",JSON.stringify({"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
