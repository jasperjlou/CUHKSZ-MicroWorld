extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("conference-registered-final-v69",Vector3(175,65,50),Vector3(80,10,-25))
	await capture("conference-shore-final-v69",Vector3(147,5,25),Vector3(108,7,-8))
	await capture("conference-icc-final-v69",Vector3(29,11,-65),Vector3(70,14,-48))
	await fixture(Vector3(112,.3,-8),[[Vector3(112,2.24,-22),"shore stair up into CxII ground platform"],[Vector3(118,2.24,-22),"CxII stair upper landing"],[Vector3(112,2.24,-22),"shore stair top return"],[Vector3(112,0,-8),"shore stair down to perimeter walk"]])
	var checks:Array=[]
	for sample:Array in [[Vector3(121,3,0),Vector3(121,-.5,0),false,"curved pond has no old terrain"],[Vector3(145,3,-25),Vector3(145,-.5,-25),true,"former rectangular lake outside new shore is land again"],[Vector3(140,.7,8),Vector3(145,.7,8),true,"outer timber bank guard"],[Vector3(110,16.5,-24),Vector3(110,14.5,-24),true,"registered curved link floor"]]:
		var q:=PhysicsRayQueryParameters3D.create(sample[0],sample[1]);q.exclude=[world.player.get_rid()]
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=(not hit.is_empty())==sample[2]
		checks.append({"case":sample[3],"valid":valid})
		if not valid:failures.append(sample[3])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"scope":"changed shore stair and final bank/pond/bridge samples;earlier ICC/CxII and full shore records not repeated"}
	FileAccess.open("res://tests/artifacts/conference_registration_visual_v69.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("CONFERENCE_REGISTRATION_VISUAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
