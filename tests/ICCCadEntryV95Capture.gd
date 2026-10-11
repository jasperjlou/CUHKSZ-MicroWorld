extends "res://tests/CourtyardRefinementCapture.gd"

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var b:Node3D=world.builder.buildings.conference
	var route:Array=[]
	for pair:Array in [
		[Vector3(-15,0,57),"outside stair guard turn"],[Vector3(-1.75,0,57),"entry stair toe"],
		[Vector3(-1.75,5,41),"main stair landing"],[Vector3(-1.75,5,26),"glazed foyer entrance"],
		[Vector3(-7,5,23),"internal stair toe"],[Vector3(-7,10,10.5),"internal gallery ascent"],
		[Vector3(3,10,10.5),"gallery cross passage"],[Vector3(-7,10,10.5),"gallery return"],
		[Vector3(-7,5,23),"internal gallery descent"],[Vector3(-1.75,5,26),"foyer return"],
		[Vector3(-1.75,5,41),"main landing return"],[Vector3(-1.75,0,57),"main stair descent"],
		[Vector3(18.5,0,57),"front apron clear of stair guards"],[Vector3(18.5,0,45),"lower lounge approach"],[Vector3(18.5,0,32),"lower public lounge entrance"],
		[Vector3(18.5,0,45),"lower lounge return"],[Vector3(31,0,45),"music wing corner"],
		[Vector3(30.5,0,-24),"music wing side return"],[Vector3(40,0,-24),"gate apron return"]]:route.append([b.to_global(pair[0]),pair[1]])
	route.append([Vector3(29,2.24,-60),"gate upper landing return"])
	await fixture(b.to_global(Vector3(-24,.3,45)),route)
	var report:Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"no_teleport_within_each_fixture":true,"scope":"CAD plan proportions and affected ICC circuit/foyer/gallery/lower lounge;global campus registration still fitted"}
	FileAccess.open("res://tests/artifacts/icc_cad_entry_v95.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ICC_CAD_V95 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
