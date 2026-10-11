extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-double-towers-final-v67",Vector3(-48,15,75),Vector3(-55,17,-15))
	await capture("gate-left-courtyard-final-v67",Vector3(-57,60,48),Vector3(-57,4,-15))
	await capture("gate-left-hall-final-v67",Vector3(-94,5,39),Vector3(-75,10,7))
	await capture("gate-left-platform-final-v67",Vector3(-56,6.2,17),Vector3(-55,6,-24))
	var checks:Array=[]
	for sample:Array in [[Vector3(-80,6,22),Vector3(-80,6,10),false,"sheltered hall approach remains open"],[Vector3(-80,7,14),Vector3(-80,9,14),true,"projecting hall has solid underside"],[Vector3(-59,5,-14),Vector3(-63,5,-14),true,"lightwell guard collision"],[Vector3(-55,4.8,-15),Vector3(-55,1,-15),false,"courtyard well is not capped by a slab"]]:
		var q:=PhysicsRayQueryParameters3D.create(sample[0],sample[1]);q.exclude=[world.player.get_rid()]
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(q)
		var valid:bool=(not hit.is_empty())==sample[2]
		checks.append({"case":sample[3],"valid":valid})
		if not valid:failures.append(sample[3])
	var report:Dictionary={"version":world.data.version,"captures":captures,"checks":checks,"failures":failures,"scope":"final bounded frontage planting/paving and4 shell/opening checks;no repeated continuous fixture"}
	FileAccess.open("res://tests/artifacts/east_gate_left_group_visual_v67.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("GATE_LEFT_VISUAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
