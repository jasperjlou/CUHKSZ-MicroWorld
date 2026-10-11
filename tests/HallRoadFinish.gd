extends "res://tests/CourtyardRefinementCapture.gd"
func wp(x: float,y: float,z: float) -> Vector3:return Vector3(-10+z,2.24+y,-885-x*80.0/90.0)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("hall-road-clearance-final-v62",Vector3(-63,8,-834),Vector3(0,5,-839))
	await capture("hall-portal-final-v62",Vector3(44,8,-888),Vector3(18,10,-899))
	await capture("sports-site-final-v62",Vector3(-100,95,-990),Vector3(-10,8,-910))
	await fixture(Vector3(44,2.54,-845),[
		[Vector3(44,2.24,-893.889),"revised Hall forecourt"],[wp(10,0,40),"revised stair approach"],
		[wp(10,.84,32),"revised stair ascent"],[wp(10,.84,12),"revised reception entry"],
		[wp(10,.84,32),"reception return"],[wp(10,0,40),"revised stair descent"],
		[Vector3(44,2.24,-893.889),"return to outer forecourt"],[Vector3(44,2.24,-838),"front to crossroad"],
		[Vector3(0,2.24,-838),"crossroad main-road junction"],[Vector3(-45,2.24,-838),"crossroad beside Hall"],
		[Vector3(-75,2.24,-838),"crossroad towards old south gate"],[Vector3(-45,2.24,-838),"crossroad return west"],
		[Vector3(0,2.24,-838),"crossroad return junction"]])
	var lanes:Array=[]
	for z in [-841.0,-838.0,-835.0]:
		var q:=PhysicsRayQueryParameters3D.create(Vector3(-75,3.3,z),Vector3(0,3.3,z))
		var hit:=world.get_world_3d().direct_space_state.intersect_ray(q);var ok:=hit.is_empty()
		lanes.append({"z":z,"clear":ok})
		if not ok:failures.append("crossroad building/terrain overlap at "+str(z))
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"road_horizontal_clearance_samples":lanes,"scope":"Final fitted80m long Hall,anchor[-10,2.24,-885],crossroadz-838 and transformed reception;3 horizontal lane samples are local collision checks,not vehicle driving certification;earlier canopy/corner legs retained where unchanged."}
	FileAccess.open("res://tests/artifacts/hall_road_finish_v62.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("HALL_ROAD_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
