extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var b:Node3D=world.builder.buildings.conference
	await capture("icc-v123-roofs",b.to_global(Vector3(65,63,78)),b.to_global(Vector3(0,13,0)))
	await capture("icc-v123-stone-windows",b.to_global(Vector3(46,8,-23)),b.to_global(Vector3(28,13,-12)))
	await capture("icc-v123-door-arcade",b.to_global(Vector3(-18,2,-42)),b.to_global(Vector3(10,4,-36)))
	await capture("icc-v123-entrance",b.to_global(Vector3(-4,7,59)),b.to_global(Vector3(0,13,36)))
	var checks:Array=[]
	for pair:Array in [[Vector3(-14,22,-16),Vector3(-14,19,-16),20.24,"main roof slab"],[Vector3(18,29,-16),Vector3(18,26,-16),27.7,"stage roof slab"],[Vector3(-1,21,25),Vector3(-1,18,25),19.54,"foyer roof slab"],[Vector3(18,18,32),Vector3(18,15,32),16.10,"music wing roof slab"]]:
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(b.to_global(pair[0]),b.to_global(pair[1])))
		var valid:bool=not hit.is_empty() and absf(hit.position.y-(b.global_position.y+pair[2]))<.06
		checks.append({"name":pair[3],"valid":valid})
		if not valid:failures.append(pair[3])
	var route:Array=[]
	for pair:Array in [[Vector3(-17,0,-40),"rear recessed doors"],[Vector3(21,0,-40),"rear stone arcade"],[Vector3(33,0,-43),"outer corner"],[Vector3(33,0,30),"windowed side avenue"],[Vector3(31,0,45),"music wing front corner"],[Vector3(18.5,0,45),"lower lounge approach"],[Vector3(18.5,.1,32),"lower lounge entrance"],[Vector3(18.5,0,57),"front apron"],[Vector3(-1.75,0,57),"main stair foot"],[Vector3(-1.75,5,41),"raised entrance landing"],[Vector3(-1.75,5,26),"main entrance"],[Vector3(-1.75,5,41),"entrance return"],[Vector3(-1.75,0,57),"stair descent"]]:route.append([b.to_global(pair[0]),pair[1]])
	await fixture(b.to_global(Vector3(-21,.3,-40)),route)
	FileAccess.open("res://tests/artifacts/icc_envelope_v123.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"checks":checks,"failures":failures,"physical_legs":legs,"fixtures":1,"scope":"ICC shell detail, planted roof/parapet support and adjacent public approaches. Not site rotation registration, roof public access or full hall interior."},"\t"))
	quit(0 if failures.is_empty() else 1)
