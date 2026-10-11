extends "res://tests/LibraryLowerLevelCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-exhibition-final-v72",wp(-14,1.75,21),wp(-22,1.7,16))
	await capture("library-arrival-final-v72",wp(-18,1.8,28.4),wp(-13.9,1.35,24))
	await capture("library-open-lower-final-v72",wp(-10,1.75,7),wp(8,1.85,-7))
	await capture("library-stair-pocket-final-v72",wp(-5.5,1.7,0),wp(1.5,2,-1))
	await fixture(wp(-18,.3,31),[
		[wp(-18,0,27),"arrival entrance after ITSO rotation"],[wp(-15.4,0,26.1),"ITSO public face outside diagonal core"],
		[wp(-13.5,0,28.6),"ITSO front corridor"],[wp(-18,0,27),"curved frontage return"],
		[wp(-18,0,31),"public exit after service visit"]])
	await fixture(wp(0,.3,12),[
		[wp(0,4.4,-4),"guarded public stair ascent"],[wp(0,0,12),"guarded public stair descent"],
		[wp(-5,0,11),"low stair side approach"],[wp(-5,0,0),"closed low void side aisle"],
		[wp(0,0,-.7),"open high underside pocket"],[wp(-5,0,0),"understair pocket return"]])
	var checks:Array=[]
	for sample:Array in [[Vector3(0,3.3,4),Vector3(4,3.3,4),"right stair guard"],[Vector3(0,3.3,4),Vector3(-4,3.3,4),"left stair guard"],[Vector3(-5,1,4),Vector3(0,1,4),"low stair storage side closure"]]:
		var a:Vector3=sample[0];var c:Vector3=sample[1]
		var q:=PhysicsRayQueryParameters3D.create(wp(a.x,a.y,a.z),wp(c.x,c.y,c.z));q.exclude=[world.player.get_rid()]
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=not hit.is_empty() and str(hit.collider.get_path()).contains("LibraryEntranceStairStructure")
		checks.append({"case":sample[2],"valid":valid,"collider":str(hit.collider.get_path()) if not hit.is_empty() else "none"})
		if not valid:failures.append(sample[2])
	var report:Dictionary={"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"scope":"ITSO corrected rotation/public approach and guarded stair/low storage closure only;initial unaffected lower-room routes retained","no_teleport_within_fixture":true}
	FileAccess.open("res://tests/artifacts/library_lower_arrival_finish_v72.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_ARRIVAL_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
