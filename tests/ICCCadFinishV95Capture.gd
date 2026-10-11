extends "res://tests/CourtyardRefinementCapture.gd"

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var b:Node3D=world.builder.buildings.conference
	await capture("icc-v95-plan",b.to_global(Vector3(60,85,85)),b.to_global(Vector3(0,5,0)))
	await capture("icc-v95-foyer",b.to_global(Vector3(-3,8,57)),b.to_global(Vector3(-1,12,36)))
	await capture("icc-v95-rear-avenue",b.to_global(Vector3(-26,2,-43)),b.to_global(Vector3(25,3,-40)))
	await capture("icc-v95-lower-lounge",b.to_global(Vector3(18.5,1.9,43)),b.to_global(Vector3(18.5,5,29)))
	var route:Array=[]
	for pair:Array in [
		[Vector3(-31,0,6),"service return clear corner"],[Vector3(-24,0,6),"foyer side turn"],
		[Vector3(-24,0,45),"long foyer side passage"],[Vector3(-1.75,0,55),"entry stair toe"],
		[Vector3(-1.75,5,41),"main stair landing"],[Vector3(-1.75,5,26),"glazed foyer entrance"],
		[Vector3(-7,5,23),"internal stair toe"],[Vector3(-7,10,10.5),"internal gallery ascent"],
		[Vector3(3,10,10.5),"gallery cross passage"],[Vector3(-7,10,10.5),"gallery return"],
		[Vector3(-7,5,23),"internal gallery descent"],[Vector3(-1.75,5,26),"foyer return"],
		[Vector3(-1.75,5,41),"main landing return"],[Vector3(-1.75,0,55),"main stair descent"],
		[Vector3(18.5,0,45),"lower lounge approach"],[Vector3(18.5,0,32),"lower public lounge entrance"],
		[Vector3(18.5,0,45),"lower lounge return"],[Vector3(31,0,45),"music wing corner"],
		[Vector3(30.5,0,-24),"music wing side return"],[Vector3(40,0,-24),"gate apron return"]]:route.append([b.to_global(pair[0]),pair[1]])
	route.append([Vector3(29,2.24,-60),"gate upper landing return"])
	await fixture(b.to_global(Vector3(-31,.3,1)),route)
	await fixture(Vector3(109,2.54,-64),[
		[Vector3(122,2.24,-64),"CxII relocated apron"],[Vector3(122,2.24,-55),"CxII lower entrance"],
		[Vector3(122,2.24,-64),"CxII entrance return"],[Vector3(109,2.24,-64),"ICC CxII cross link"],
		[Vector3(109,2.24,-78),"ICC side street rejoin"],[Vector3(109,2.24,-64),"cross link return"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":2,"no_teleport_within_each_fixture":true,"scope":"CAD plan proportions and affected ICC circuit/foyer/gallery/lower lounge;global campus registration still fitted"}
	FileAccess.open("res://tests/artifacts/icc_cad_finish_v95.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ICC_CAD_V95 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
