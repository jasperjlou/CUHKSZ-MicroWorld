extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-registered-axis-v66",Vector3(0,6,43),Vector3(0,7,-37))
	await capture("gate-right-portal-v66",Vector3(3,8,-13),Vector3(33,19,-21))
	await capture("gate-registration-overview-v66",Vector3(-27,63,76),Vector3(5,0,-12))
	await fixture(Vector3(0,-.06,36),[
		[Vector3(0,-.36,24.5),"lower exterior pavement"],
		[Vector3(0,0,19.5),"three shallow front treads"],
		[Vector3(-12,0,19.5),"front apron to left approach"],
		[Vector3(-12,0,-3),"name stone and four huabiao left bypass"],
		[Vector3(-12,0,-15),"left cross-street pedestrian crossing"],
		[Vector3(0,0,-20),"inner square centre"],
		[Vector3(0,0,-39),"single bridge to broad stair"],
		[Vector3(0,2.24,-54),"main stair top"],
		[Vector3(0,0,-39),"main stair return"],
		[Vector3(17,0,-34),"court to side ramp foot"],
		[Vector3(17,2.24,-65),"ramp beside round bridge pier"],
		[Vector3(17,0,-34),"ramp descent"],
		[Vector3(22,0,-24),"portal-side sidewalk"],
		[Vector3(31,.256,-24),"right vehicle lane grade foot"],
		[Vector3(31,2.24,-55),"right lane below tall undercroft to ICC interface"],
		[Vector3(31,.256,-24),"right lane grade descent"],
		[Vector3(31,0,15),"side vehicle entry beside relocated median"],
		[Vector3(22,0,15),"lane to pedestrian forecourt"],
		[Vector3(12,0,15),"right stone approach"],
		[Vector3(12,0,-3),"name stone and huabiao right bypass"],
		[Vector3(-12,0,-3),"behind stone monument"],
		[Vector3(-12,0,19.5),"left return approach"],
		[Vector3(0,0,19.5),"front stair head return"],
		[Vector3(0,-.36,36),"three treads back to exterior"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"fixtures":1,"no_teleport_within_fixture":true,"scope":"ceremonial plaza, right vehicle entry, single bridge, right undercroft and grade;metric offsets and missing left/low wings still fitted/incomplete"}
	FileAccess.open("res://tests/artifacts/east_gate_registration_v66.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("EAST_GATE_REGISTRATION ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
