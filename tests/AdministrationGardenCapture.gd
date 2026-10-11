extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("admin-garden-overview-v71",Vector3(177,39,-145),Vector3(131,15,-180))
	await capture("admin-garden-pavilion-v71",Vector3(131,17.5,-180),Vector3(152,19.3,-180))
	await capture("admin-garden-downhill-v71",Vector3(149,18,-177),Vector3(116,14,-180))
	await capture("admin-garden-road-v71",Vector3(143,18,-207),Vector3(123,15,-185))
	await fixture(Vector3(112,14.94,-180),[
		[Vector3(123,14.64,-180),"admin terrace garden approach"],[Vector3(132,15.24,-180),"first garden flight"],
		[Vector3(141,15.84,-180),"second garden flight"],[Vector3(147,16.44,-180),"third garden flight"],
		[Vector3(152,16.74,-180),"pavilion raised plinth entry"],[Vector3(153,16.74,-178.8),"inside pavilion corner"],
		[Vector3(152,16.74,-180),"pavilion centre return"],[Vector3(147,16.44,-180),"pavilion plinth descent"],
		[Vector3(141,15.84,-180),"third flight descent"],[Vector3(132,15.24,-180),"second flight descent"],
		[Vector3(124,14.64,-180),"first flight descent"],[Vector3(124,14.64,-200),"garden side path to rear road"],
		[Vector3(137,14.64,-200),"library rear road junction"],[Vector3(137,world.builder.height(137,-230),-230),"rear road descent toward library"],
		[Vector3(137,14.64,-200),"rear road return to garden junction"],[Vector3(124,14.64,-200),"garden side path return"],
		[Vector3(124,14.64,-180),"garden to admin threshold"],[Vector3(112,14.64,-180),"admin rear platform return"]])
	var checks:Array=[]
	for sample:Array in [[Vector3(152,17.5,-180),Vector3(152,16,-180),true,"pavilion solid floor"],[Vector3(152,18,-180),Vector3(152,23,-180),true,"pavilion curved roof overhead"],[Vector3(147.5,18,-180),Vector3(153,18,-180),false,"open pavilion entry"],[Vector3(137,20,-200),Vector3(137,13,-200),true,"retained rear-road junction"]]:
		var q:=PhysicsRayQueryParameters3D.create(sample[0],sample[1]);q.exclude=[world.player.get_rid()]
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=(not hit.is_empty())==sample[2]
		checks.append({"case":sample[3],"valid":valid})
		if not valid:failures.append(sample[3])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"scope":"admin hill pavilion/stone stairs and affected rear-road junction only;dates and metric placement remain fitted","no_teleport_within_fixture":true}
	FileAccess.open("res://tests/artifacts/admin_garden_v71.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ADMIN_GARDEN ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
