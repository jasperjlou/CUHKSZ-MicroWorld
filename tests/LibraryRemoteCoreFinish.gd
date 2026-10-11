extends "res://tests/LibraryLowerLevelCapture.gd"
const Remote:=preload("res://world/visual_campus/LibraryRemoteCore.gd")
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-remote-stair-final-v73",wp(-35.8,1.8,-8.3),wp(-38.7,3.0,-15.5))
	await capture("library-remote-toilets-final-v73",wp(-30.5,1.8,-20),wp(-34,1.8,-21.0))
	await capture("library-remote-upper-final-v73",wp(-30,18.6,-19.8),wp(-34.0,18.6,-19.8))
	await capture("library-rear-core-final-v73",wp(-29,1.8,-21),wp(-33,1.8,-16))
	for i in Remote.LEVELS.size():
		var y:float=Remote.LEVELS[i]
		await fixture(wp(-32.5,y+.3,-8.3),[[wp(-32.5,y,-18.8),str(i+1)+"F water/toilet corridor"],[wp(-32.5,y,-22.0 if i<2 else -21),str(i+1)+"F restroom door frontage"],[wp(-32.5,y,-8.3),str(i+1)+"F corridor return"],[wp(-35.85,y,-8.3),str(i+1)+"F stair landing connection"]])
	await fixture(wp(-32.5,.3,-22),[[wp(-32.5,0,-19),"lower corridor back to ramp foot"],[wp(-30,0,-19),"rear ramp aligned approach"],[wp(-30,.48,-24),"rear inner ramp ascent"],[wp(-30,.48,-27),"rear door to porch"],[wp(-30,0,-32),"rear stair to paved path"],[wp(-30,.48,-27),"rear porch return"],[wp(-30,0,-19),"rear inner descent"],[wp(-31,0,-8),"lower learning aisle return"]])
	var checks:Array=[]
	for y:float in Remote.LEVELS:
		var q:=PhysicsRayQueryParameters3D.create(wp(-32,y+1.5,-18.6),wp(-35,y+1.5,-18.6));q.exclude=[world.player.get_rid()]
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=not hit.is_empty() and str(hit.collider.get_path()).contains("RemoteToiletFrontage")
		checks.append({"case":"toilet frontage built at "+str(y),"valid":valid})
		if not valid:failures.append("missing toilet frontage at "+str(y))
	var report:Dictionary={"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"scope":"all5 restroom-front corridors after runtime type repair and rear-porch ramp connection;unchanged stair flight records retained separately","no_teleport_within_fixture":true}
	FileAccess.open("res://tests/artifacts/library_remote_core_finish_v73.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_REMOTE_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
