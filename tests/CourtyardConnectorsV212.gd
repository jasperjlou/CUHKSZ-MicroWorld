extends "res://tests/LibraryLowerRearV150.gd"
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(Vector3(56,8,-350),Vector3(56,10,-350),false,"cross-link extra roof removed",checks)
	probe(Vector3(56,6.9,-350),Vector3(56,6,-350),true,"retained deck support",checks)
	probe(Vector3(56,4,-350),Vector3(56,5.8,-350),false,"lower colonnade headroom",checks)
	for side:float in [-1,1]:probe(Vector3(56+side*1.9,7.3,-350),Vector3(56+side*2.3,7.3,-350),true,"upper cross-link edge guard "+str(side),checks)
	probe(Vector3(30,8,-331),Vector3(30,10,-331),true,"side gallery roof retained",checks)
	await fixture(Vector3(56,6.94,-375),[[Vector3(56,6.64,-350),"cross-link to library"],[Vector3(56,6.64,-331),"open end junction"],[Vector3(35,6.64,-331),"side gallery"],[Vector3(13,6.64,-331),"side gallery end"],[Vector3(35,6.64,-331),"side gallery return"],[Vector3(56,6.64,-331),"junction return"],[Vector3(56,6.64,-350),"cross-link return"],[Vector3(56,6.64,-375),"student fitted upper endpoint"]])
	await fixture(Vector3(56,2.54,-365),[[Vector3(56,2.24,-350),"ground double columns"],[Vector3(56,2.24,-337),"library-side ground approach"],[Vector3(56,2.24,-350),"ground return"],[Vector3(56,2.24,-365),"student ground approach"]])
	await fixture(Vector3(13,6.94,-400),[[Vector3(28,6.64,-400),"student side gallery"],[Vector3(40,6.64,-400),"student side facade approach"],[Vector3(28,6.64,-400),"student side return"],[Vector3(13,6.64,-400),"student side gallery end"]])
	root.disable_3d=false;await frames(12)
	await capture("courtyard-connectors-v212-wide",Vector3(-9,17,-365),Vector3(49,7,-350))
	await capture("courtyard-connectors-v212-under",Vector3(56,3.95,-342),Vector3(56,4,-367))
	await capture("courtyard-connectors-v212-side",Vector3(29,3.95,-396),Vector3(42,5,-400))
	await capture("courtyard-connectors-v212-upper",Vector3(56,8.35,-350),Vector3(56,7.6,-369))
	FileAccess.open("res://tests/artifacts/courtyard_connectors_v212.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"scope":"three local gallery fixtures,roof silhouette and guards;upperdeck real use/endpoints not established"},"\t"))
	print("COURTYARD_CONNECTORS_V212 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
