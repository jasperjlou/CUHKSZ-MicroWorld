extends "res://tests/ZhangDatumV137.gd"
const T197:=preload("res://world/visual_campus/TeachingOuterGrade.gd")
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("teaching-outer-v197-apron",Vector3(-134,-.1,-90),Vector3(-130,0,-146))
	await capture("teaching-outer-v197-gate-rise",Vector3(-148,-.62,-167),Vector3(-60,3,-167))
	await capture("teaching-outer-v197-outside",Vector3(-174,-.62,-178),Vector3(-135,6,-127))
	await capture("teaching-outer-v197-plan",Vector3(-183,44,-185),Vector3(-114,0,-136))
	var route:Array=[]
	for p:Vector3 in [Vector3(-125,-1.83,-112),Vector3(-142,-1.83,-112),Vector3(-142,-1.83,-139),Vector3(-132,-1.83,-139),Vector3(-125,-1.83,-148),Vector3(-125,-2.325,-167),Vector3(-135.12,-2.325,-167),Vector3(-135.12,-2.325,-202),Vector3(-148,-2.325,-202),Vector3(-174,-2.325,-202),Vector3(-174,-2.325,-178),Vector3(-148,-2.325,-178),Vector3(-143,-2.325,-167),Vector3(-121.8,-2.325,-167),Vector3(-100,T197.axis(-100),-167),Vector3(-75,T197.axis(-75),-167),Vector3(-54,2.24,-167),Vector3(-35,2.24,-167)]:route.append([p,"rear to mall "+str(p)])
	await fixture(Vector3(-125,-1.53,-90),route)
	var reverse:Array=[]
	for item:Array in route.duplicate():reverse.push_front([item[0],"return "+str(item[0])])
	if failures.is_empty():await fixture(Vector3(-35,2.54,-167),reverse.slice(1))
	for item:Array in [[Vector3(-135,-1.83,-112),"open rear apron"],[Vector3(-145,-2.325,-167),"south gate low datum"],[Vector3(-100,T197.axis(-100),-167),"rising promenade"],[Vector3(-54,2.24,-167),"mall upper tie"]]:
		var p:Vector3=item[0];var hit:=world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(p+Vector3.UP*.5,p-Vector3.UP*.5,1))
		var ok:bool=not hit.is_empty() and absf(hit.position.y-p.y)<.12
		checks.append({"label":item[1],"valid":ok,"hit_y":hit.position.y if not hit.is_empty() else -999});if not ok:failures.append(item[1])
	probe("old upper overpass removed",Vector3(-132,3,-167),Vector3(-132,.5,-167),false)
	probe("A outer wall removed",Vector3(-125,-.5,-112),Vector3(-139,-.5,-112),false)
	probe("B outer wall removed",Vector3(-136,-.8,-202),Vector3(-148,-.8,-202),false)
	FileAccess.open("res://tests/artifacts/teaching_outer_grade_v197.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"fixtures":2,"failures":failures,"scope":"A/B lower outer apron and rising South Gate axis;metric fit and floor ownership still partial;retire V140 upper bridge and V196 old flat-grade checks"},"\t"))
	quit(0 if failures.is_empty() else 1)
