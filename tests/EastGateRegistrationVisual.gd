extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-axis-final-v66",Vector3(0,6,43),Vector3(0,7,-37))
	await capture("gate-portal-final-v66",Vector3(3,8,-13),Vector3(33,19,-21))
	await capture("gate-road-final-v66",Vector3(29,5,22),Vector3(29,6,-50))
	var results:Array=[]
	for sample:Array in [[Vector3(0,12.6,-1),Vector3(0,12.6,-11),false,"retired front bridge volume is empty"],[Vector3(19.5,1,-34),Vector3(19.5,1,-41),true,"round bridge pier collision"],[Vector3(8,18.7,-31),Vector3(28,18.7,-31),true,"upper recessed loggia front guard"]]:
		var query:=PhysicsRayQueryParameters3D.create(sample[0],sample[1]);query.exclude=[world.player.get_rid()]
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(query)
		var valid:bool=(not hit.is_empty())==sample[2]
		results.append({"case":sample[3],"expected_hit":sample[2],"valid":valid})
		if not valid:failures.append(sample[3])
	var report:Dictionary={"version":world.data.version,"captures":captures,"checks":results,"failures":failures,"scope":"final stone/metal colour, vegetation moved off side road;one added upper loggia guard checked locally;no repeated ground fixture"}
	FileAccess.open("res://tests/artifacts/east_gate_registration_visual_v66.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("GATE_REGISTRATION_VISUAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
