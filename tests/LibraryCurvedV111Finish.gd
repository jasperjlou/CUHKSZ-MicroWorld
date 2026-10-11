extends "res://tests/LibraryUpperPlanV110.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false)
	var route:Array=[]
	for p in [[840,795],[797,754],[760,722],[725,696],[680,680],[625,674],[625,710],[625,674],[680,680],[725,696],[760,722],[797,754],[840,795],[870,825]]:route.append([pp(p[0],p[1],20.8),"6F final bent bridge "+str(p)])
	await fixture(pp(870,825,21.1),route)
	var checks:Array=[]
	for sample in [[680,680,true,"bent bridge retained"],[730,680,false,"outside bend is void"],[625,674,true,"left landing retained"]]:
		var q=PhysicsRayQueryParameters3D.create(pp(sample[0],sample[1],20.95),pp(sample[0],sample[1],20.65));q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var ok:bool=(not hit.is_empty())==sample[2];checks.append({"case":sample[3],"valid":ok});if not ok:failures.append(sample[3])
	var report={"version":world.data.version,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":1,"scope":"Affected6Fbridge only after removing residual slab outside bend"}
	FileAccess.open("res://tests/artifacts/library_curved_v111_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_CURVED_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
