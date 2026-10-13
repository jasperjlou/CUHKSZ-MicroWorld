extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var headless:bool=DisplayServer.get_name()=="headless"
	if headless:
		var route:Array=[]
		for p in [[-201,-680],[-201,-735],[-201,-790],[-201,-832],[-201,-790],[-191.7,-790],[-181,-790],[-168,-790],[-130,-790],[-70,-790],[-16,-790],[-70,-790],[-130,-790],[-181,-790],[-181,-815],[-181,-790],[-181,-750],[-181,-682],[-169.9,-682],[-154,-682],[-162.5,-682],[-162.5,-711],[-162.5,-755],[-162.5,-782.8],[-181,-782.8],[-191.7,-782.8],[-191.7,-790],[-191.7,-816]]:
			route.append([Vector3(p[0],2.24,p[1]),"registered street/gate/forecourt "+str(p)])
		await fixture(Vector3(-201,2.64,-651),route)
	else:
		await capture("old-gate-v217-plan",Vector3(-244,93,-723),Vector3(-127,3,-757))
		await capture("old-gate-v217-entry",Vector3(-203,4.1,-790),Vector3(-156,8.4,-799))
		await capture("old-gate-v217-street",Vector3(-205,4.1,-772),Vector3(-199,3.6,-818))
		await capture("old-gate-v217-daoyuan",Vector3(-176.5,4.1,-785),Vector3(-163,7,-741))
	var suffix:String="physical" if headless else "visual"
	FileAccess.open("res://tests/artifacts/old_gate_site_v217_"+suffix+".json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"captures":captures,"failures":failures,"scope":"continuous pedestrian street/entry/forecourt and affected clock-end lane; no vehicle dynamics or surveyed topology claim"},"\t"))
	print("OLD_GATE_SITE_V217 ",JSON.stringify({"mode":suffix,"legs":legs.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
