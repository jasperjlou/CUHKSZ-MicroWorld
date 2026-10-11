extends "res://tests/CourtyardRefinementCapture.gd"

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var b:Node3D=world.builder.buildings.conference
	await capture("icc-v94-door-avenue",b.to_global(Vector3(-29,1.8,8)),b.to_global(Vector3(18,2.3,4)))
	await capture("icc-v94-undercroft",b.to_global(Vector3(-13,1.9,24)),b.to_global(Vector3(17,2.2,13)))
	await capture("icc-v94-stair-court",b.to_global(Vector3(31,12,48)),b.to_global(Vector3(2,2.4,23)))
	await capture("icc-v94-gate-side",Vector3(32,9,-69),Vector3(62,5,-48))
	var route:Array=[
		[b.to_global(Vector3(-13,0,35)),"gate side apron"],[b.to_global(Vector3(-13,0,8)),"lower avenue side entry"],
		[b.to_global(Vector3(-28,0,8)),"door row first bay"],[b.to_global(Vector3(35,0,8)),"long avenue through open column bays"],
		[b.to_global(Vector3(39,0,12)),"projecting wing side turn"],[b.to_global(Vector3(39,0,28)),"outer bed bypass"],
		[b.to_global(Vector3(16,0,28)),"forecourt beneath platform edge"],[b.to_global(Vector3(16,0,22)),"new stone undercroft"],
		[b.to_global(Vector3(5,0,22)),"clear central undercroft aisle"],[b.to_global(Vector3(5,0,8)),"undercroft to door avenue"],
		[b.to_global(Vector3(-13,0,8)),"hedge-side passage return"],[b.to_global(Vector3(-13,0,36)),"outer apron around hedge"],
		[b.to_global(Vector3(5,0,36)),"main stair toe"],[b.to_global(Vector3(5,4.4,24)),"main stair to raised landing"],
		[b.to_global(Vector3(5,4.4,13)),"foyer entrance retained"],[b.to_global(Vector3(5,4.4,24)),"foyer landing return"],
		[b.to_global(Vector3(5,0,36)),"main stair descent"],[b.to_global(Vector3(-13,0,36)),"apron to gate return"],
		[Vector3(35,2.24,-53),"gate connecting walk return"],[Vector3(29,2.24,-60),"gate upper landing rejoin"]]
	await fixture(Vector3(29,2.54,-60),route)
	var report:Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"V94 bounded planting,continuous ICC undercroft stone,added foyer supports and affected gate/stair connections;full ICC spatial registration remains fitted"}
	FileAccess.open("res://tests/artifacts/icc_ground_v94.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ICC_GROUND_V94 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
