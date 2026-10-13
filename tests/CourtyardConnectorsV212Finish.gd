extends "res://tests/LibraryLowerRearV150.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(Vector3(30,8,-331),Vector3(30,10,-331),true,"side gallery roof now blocks camera",checks)
	probe(Vector3(30,6.75,-331),Vector3(30,8.5,-331),false,"side gallery standing headroom remains",checks)
	probe(Vector3(56,8,-350),Vector3(56,10,-350),false,"white cross-link remains one slab",checks)
	await capture("courtyard-connectors-v212-final-side",Vector3(29,3.95,-396),Vector3(42,5,-400))
	await capture("courtyard-connectors-v212-final-wide",Vector3(-9,17,-365),Vector3(49,7,-350))
	FileAccess.open("res://tests/artifacts/courtyard_connectors_v212_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"captures":captures,"failures":failures,"scope":"side-gallery roof collision added above headroom;initial16legs unchanged walking surfaces"},"\t"))
	print("COURTYARD_CONNECTORS_V212_FINISH ",JSON.stringify({"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
