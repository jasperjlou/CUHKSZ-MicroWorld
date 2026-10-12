extends "res://tests/LibraryCoreBoundaryV147.gd"
func walk(target:Vector3,label:String)->bool:
	var valid:bool=await super.walk(target,label)
	if not valid:
		var player=world.player;var delta:Vector3=target-player.global_position;delta.y=0
		var collision:=KinematicCollision3D.new()
		if player.test_move(player.global_transform,delta.normalized()*.2,collision):print("BLOCK ",collision.get_collider().get_path()," ",collision.get_position())
	return valid

func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	# Diagnose the two rejected targets before resuming; no geometry changed.
	var old=JSON.parse_string(FileAccess.get_file_as_string("res://tests/artifacts/library_core_boundary_v147.json"))
	for leg in old.physical_legs:
		if leg.valid:continue
		var pos:=Vector3(leg.end[0],leg.end[1],leg.end[2]);var shape:=SphereShape3D.new();shape.radius=.6
		var q:=PhysicsShapeQueryParameters3D.new();q.shape=shape;q.transform=Transform3D(Basis.IDENTITY,pos+Vector3.UP);q.exclude=[world.player.get_rid()]
		for hit in world.get_world_3d().direct_space_state.intersect_shape(q,8):print("INITIAL_CONTACT ",leg.goal," ",hit.collider.get_path())
	var route:Array=[]
	for p in [Vector3(5,12.8,-3.8),Vector3(1.45,12.8,-3.8),Vector3(-1.45,12.8,-3.8),Vector3(-1.45,14.8,3.8),Vector3(1.45,14.8,3.8),Vector3(1.45,16.8,-3.8),Vector3(5,16.8,-3.8),Vector3(1.45,16.8,-3.8)]:route.append([lp(p.x,p.y,p.z),"4F5F doorway and final ascent "+str(p)])
	for i in range(4,0,-1):
		var y:float=Core.LEVELS[i];var below:float=Core.LEVELS[i-1];var half:float=(y+below)/2
		for p in [Vector3(1.45,half,3.8),Vector3(-1.45,half,3.8),Vector3(-1.45,below,-3.8),Vector3(1.45,below,-3.8)]:route.append([lp(p.x,p.y,p.z),"left core descent "+str(p)])
	for p in [Vector3(5,0,-3.8),Vector3(1.45,0,-3.8)]:route.append([lp(p.x,p.y,p.z),"G public exit "+str(p)])
	await fixture(lp(1.45,13.1,-3.8),route)
	var sixth:Array=[]
	for p in [[900,780],[900,650],[950,730],[1020,760],[1010,680],[990,625],[970,590],[970,460],[950,400],[800,400],[790,490],[790,640],[900,650],[900,780],[870,825]]:sixth.append([p6(p[0],p[1],20.8),"6F actual outer aisle "+str(p)])
	await fixture(p6(870,825,21.1),sixth)
	FileAccess.open("res://tests/artifacts/library_core_boundary_v147_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"failures":failures,"fixtures":2,"geometry_changed":false},"\t"))
	print("LIBRARY_CORE_V147_FINISH ",JSON.stringify({"legs":legs.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
