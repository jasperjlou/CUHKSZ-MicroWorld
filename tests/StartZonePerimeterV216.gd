extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var headless:bool=DisplayServer.get_name()=="headless"
	if headless:
		var route:Array=[]
		for p in [[-169.9,-676.4],[-181,-676.4],[-181,-635],[-181,-676.4],[-181,-734],[-181,-782.8],[-163,-782.8],[-162.5,-755],[-162.5,-711],[-162.5,-682],[-174,-682],[-174,-748],[-177,-750],[-177,-782.8],[-181,-782.8],[-181,-835],[-181,-782.8]]:
			route.append([Vector3(p[0],2.24,p[1]),"outer walk/gate/DaoYuan return "+str(p)])
		await fixture(Vector3(-154,2.64,-676.4),route)
	else:
		await capture("start-perimeter-v216-plan",Vector3(-240,102,-690),Vector3(-117,4,-729))
		await capture("start-perimeter-v216-walk",Vector3(-180.6,4.0,-670),Vector3(-181,3.7,-715))
		await capture("start-perimeter-v216-branch",Vector3(-154,4.4,-676.4),Vector3(-180,3.8,-680))
		await capture("start-perimeter-v216-gate",Vector3(-206,12,-781),Vector3(-162,5,-792))
	var suffix:String="physical" if headless else "visual"
	FileAccess.open("res://tests/artifacts/start_zone_perimeter_v216_"+suffix+".json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"captures":captures,"failures":failures,"scope":"one continuous local outer walk/old-gate/DaoYuan fixture; fitted topology, not accessibility or whole-campus certification"},"\t"))
	print("START_ZONE_PERIMETER_V216 ",JSON.stringify({"mode":suffix,"legs":legs.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
