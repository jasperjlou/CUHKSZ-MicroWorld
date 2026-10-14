extends "res://tests/LibraryLowerLevelCapture.gd"
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(20)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	# Walk along the existing pavement past the garden and through the retained side door.
	var b:Node3D=world.builder.buildings.shaw_east
	await fixture(Vector3(61,2.54,-579),[[Vector3(70,2.24,-579),"stone frontage"],[Vector3(80,2.24,-579),"garden to side door"],[b.to_global(Vector3(-39,0,0)),"side stair foot"],[b.to_global(Vector3(-32,.45,0)),"side doorway"],[b.to_global(Vector3(-39,0,0)),"side exit"],[Vector3(91,2.24,-579),"corner sidewalk continuation"]])
	var checks:Array=[]
	for x:float in [68.0,70.0,72.0]:
		var q=PhysicsRayQueryParameters3D.create(Vector3(x,3.3,-578),Vector3(x,3.3,-574));q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q)
		var valid:bool=not hit.is_empty() and "RoundedShawStoneV248" in str(hit.collider.get_path())
		checks.append({"case":"lettered stone face "+str(x),"valid":valid})
		if not valid:failures.append("stone collision "+str(x))
	root.disable_3d=false;await frames(15)
	await capture("shaw-stone-v248-front",Vector3(69,4.1,-584),Vector3(70,3.25,-575.5))
	await capture("shaw-stone-v248-garden",Vector3(77,4.5,-579),Vector3(71,2.85,-575.6))
	await capture("shaw-stone-v248-corner",Vector3(56,6.0,-591),Vector3(72,5,-570))
	FileAccess.open("res://tests/artifacts/shaw_stone_garden_v248.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"checks":checks,"physical_legs":legs,"failures":failures,"scope":"stone shape and garden only;6 sidewalk/door legs,3stone rays;not campus/camera acceptance;location and dimensions remain fitted"},"\t"))
	print("SHAW_STONE_V248 ",JSON.stringify({"legs":legs.size(),"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
