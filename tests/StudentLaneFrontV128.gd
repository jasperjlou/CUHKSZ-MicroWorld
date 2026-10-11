extends "res://tests/CourtyardRefinementCapture.gd"
var checks:Array=[]
func probe(label:String,a:Vector3,b:Vector3,expected:bool) -> void:
	var q:=PhysicsRayQueryParameters3D.create(a,b,1)
	var hit:=not world.get_world_3d().direct_space_state.intersect_ray(q).is_empty()
	checks.append({"label":label,"valid":hit==expected,"hit":hit})
	if hit!=expected:failures.append(label)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	if DisplayServer.get_name()!="headless":
		await capture("student-front-v128-hall-out",Vector3(29,-.03,-447),Vector3(25,.03,-461))
		await capture("student-front-v128-bays",Vector3(30,-.08,-465),Vector3(24.6,-.02,-456))
		await capture("student-front-v128-utility",Vector3(27.2,-.15,-451.7),Vector3(23.8,-.18,-453))
		await capture("student-front-v128-shaw-return",Vector3(29,2.4,-483),Vector3(26,.1,-457))
		FileAccess.open("res://tests/artifacts/student_front_v128_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	await fixture(Vector3(29,-1.46,-446),[
		[Vector3(28,-1.76,-453),"first service bay approach"],[Vector3(24.45,-1.76,-453),"service door threshold"],
		[Vector3(28,-1.76,-453),"utility recess exit"],[Vector3(28,-1.76,-457),"second bay approach"],
		[Vector3(24.45,-1.76,-457),"second bay sheltered recess"],[Vector3(28,-1.76,-457),"second bay return"],
		[Vector3(28,-1.76,-461),"third bay approach"],[Vector3(24.45,-1.76,-461),"third bay sheltered recess"],
		[Vector3(28,-1.76,-461),"third bay return"],[Vector3(28,-1.76,-465),"fourth bay approach"],
		[Vector3(24.45,-1.76,-465),"fourth bay sheltered recess"],[Vector3(28,-1.76,-465),"fourth bay return"],
		[Vector3(29,-1.76,-467),"frontage to fitted rising lane"],[Vector3(29,.24,-480),"rising road"],
		[Vector3(29,2.24,-494),"Shaw apron"],[Vector3(29,.24,-480),"road return"],
		[Vector3(29,-1.76,-465),"frontage return"],[Vector3(29,-1.76,-446),"covered hall return"]])
	probe("glazed infill has collision",Vector3(24.5,-.4,-461),Vector3(23.5,-.4,-461),true)
	probe("utility door remains closed",Vector3(24.5,-.4,-452.5),Vector3(23.5,-.4,-452.5),true)
	probe("pier has collision",Vector3(26,-.4,-459),Vector3(24.6,-.4,-459),true)
	probe("canopy clear headroom",Vector3(25.6,-1.7,-461),Vector3(25.6,.55,-461),false)
	FileAccess.open("res://tests/artifacts/student_front_v128_physics.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":1,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
