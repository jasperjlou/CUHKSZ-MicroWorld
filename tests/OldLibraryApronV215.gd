extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var headless:bool=DisplayServer.get_name()=="headless"
	if headless:
		var route:Array=[]
		for p in [[-94,-676.4],[-104,-676.4],[-116.5,-676.4],[-116.5,-658],[-103,-658],[-90,-658],[-90,-676.4],[-90,-682],[-125,-682],[-154,-682],[-125,-682],[-86,-682]]:
			route.append([Vector3(p[0],2.24,p[1]),"bus apron pedestrian/through road "+str(p)])
		await fixture(Vector3(-86,2.64,-676.4),route)
	else:
		await capture("old-library-apron-v215-approach",Vector3(-77,4.2,-675.7),Vector3(-104,3.7,-670))
		await capture("old-library-apron-v215-layout",Vector3(-81,22,-693),Vector3(-105,3,-668))
		await capture("old-library-apron-v215-coach",Vector3(-95,5.3,-679.5),Vector3(-104,4.2,-673.9))
		await capture("old-library-apron-v215-kerb",Vector3(-25,3.8,-676.4),Vector3(-53,3.1,-682))
		# Diagnostic only: retain normal-light capture; do not ship a disabled sun shadow.
		for light in world.find_children("*","DirectionalLight3D",true,false):light.shadow_enabled=false
		await capture("old-library-apron-v215-kerb-no-shadow-diagnostic",Vector3(-25,3.8,-676.4),Vector3(-53,3.1,-682))
	var suffix:String="physical" if headless else "visual"
	FileAccess.open("res://tests/artifacts/old_library_apron_v215_"+suffix+".json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"captures":captures,"failures":failures,"scope":"fitted bus apron access and retained through road; sun-off image diagnostic only"},"	"))
	print("OLD_LIBRARY_APRON_V215 ",JSON.stringify({"mode":suffix,"legs":legs.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
