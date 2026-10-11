extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("bc-v121-b-front",Vector3(-15,8,-183),Vector3(-51,8,-217))
	await capture("bc-v121-b-lobby",Vector3(-49,4.1,-207),Vector3(-59,5.2,-211))
	await capture("bc-v121-c-arcade",Vector3(-43,4.1,-302),Vector3(-50,6.8,-341))
	await capture("bc-v121-c-door",Vector3(-43,4.1,-340),Vector3(-51,6,-343))
	await capture("bc-v121-aprons",Vector3(-14,29,-256),Vector3(-50,3,-278))
	await fixture(Vector3(-39,2.54,-207),[
		[Vector3(-53.72,2.24,-207),"B awning apron to lobby"],
		[Vector3(-53.72,2.24,-220),"B lobby to side corridor"],
		[Vector3(-53.72,2.24,-207),"B corridor return"],
		[Vector3(-70,2.24,-207),"B lobby rear exit"],
		[Vector3(-82,2.24,-207),"B court"],
		[Vector3(-82,2.24,-200.56),"B stair approach"],
		[Vector3(-78.5,2.24,-200.56),"B stair foot"],
		[Vector3(-61.5,7.165,-200.56),"B stair landing"],
		[Vector3(-55,7.165,-200.56),"B inner gallery"],
		[Vector3(-47,7.165,-200.56),"B connected recessed outer deck"],
		[Vector3(-47,7.165,-218),"B outer deck along screen"],
		[Vector3(-47,7.165,-200.56),"B outer deck return"],
		[Vector3(-61.5,7.165,-200.56),"B gallery to stair"],
		[Vector3(-82,2.24,-200.56),"B continuous stair descent"]])
	await fixture(Vector3(-39,2.54,-258.5),[
		[Vector3(-39,2.24,-272.5),"B apron to B C cross path"],
		[Vector3(-39,2.24,-286.5),"cross path to C apron"],
		[Vector3(-39,2.24,-343),"C mall edge to awning"],
		[Vector3(-53,2.24,-343),"C door beneath transom"],
		[Vector3(-59,2.24,-340),"C diagonal vestibule"],
		[Vector3(-86.62,2.24,-327.88),"C diagonal hall"],
		[Vector3(-119,2.24,-313.4),"C rear stone exit"],
		[Vector3(-135.12,2.24,-312.76),"C rear perimeter"],
		[Vector3(-135.12,2.24,-272.5),"C perimeter to B C rear junction"],
		[Vector3(-39,2.24,-272.5),"rear junction back to mall"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":2,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"B entrance/court/stair/recessed deck and C entrance/rear through B C cross path. Dimensions/awning offsets/connector fitted; no full massing or geographic registration claim."}
	FileAccess.open("res://tests/artifacts/teaching_bc_v121.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TEACHING_BC_V121 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
