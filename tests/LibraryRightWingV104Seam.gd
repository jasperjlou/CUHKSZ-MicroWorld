extends "res://tests/LibraryStudyPodsV101Capture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-right-v104-seam",wp(19,2.2,22),wp(22.55,2.0,16.2))
	await fixture(wp(16,.3,24),[[wp(24,0,24),"116 to pavilion front walk"],[wp(44.7,0,24),"pavilion broadside walk"],[wp(46,0,13),"pavilion glazed end"],[wp(44.7,0,24),"glazed end return"],[wp(16,0,24),"front walk return"]])
	var checks:Array=[]
	for s in [[Vector3(21.8,1.5,16.25),Vector3(23.3,1.5,16.25),true,"junction closed"],[Vector3(17,1.5,12),Vector3(25,1.5,12),false,"no internal cross wall"]]:
		var a:Vector3=s[0];var b:Vector3=s[1];var q=PhysicsRayQueryParameters3D.create(wp(a.x,a.y,a.z),wp(b.x,b.y,b.z));q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=(not hit.is_empty())==s[2]
		checks.append({"case":s[3],"valid":valid})
		if not valid:failures.append(s[3])
	var report={"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1}
	FileAccess.open("res://tests/artifacts/library_right_wing_v104_seam.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_RIGHT_SEAM ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
