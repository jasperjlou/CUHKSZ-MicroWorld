extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-square-v38",Vector3(-2,3.0,-16),Vector3(0,6,-55))
	await capture("gate-ramp-v38",Vector3(13,5,-29),Vector3(17.0,2,-51))
	await capture("gate-landing-v38",Vector3(-30,25,-54),Vector3(2,2,-74))
	await fixture(Vector3(0,.3,-16),[
		[Vector3(0,0,-39),"stone court to stair foot"],
		[Vector3(0,2.24,-54),"broad stair ascent"],
		[Vector3(0,2.24,-98),"upper lawn middle passage"],
		[Vector3(20,2.24,-98),"upper lawn crosswalk"],
		[Vector3(17.0,2.24,-65),"side ramp upper landing"],
		[Vector3(17.0,0,-34),"side ramp descent"],
		[Vector3(17.0,2.24,-65),"side ramp ascent"],
		[Vector3(20,2.24,-98),"ramp to mall apron"],
		[Vector3(20,2.24,-170),"mall to administration frontage"],
		[Vector3(36,2.24,-170),"administration walk interface"],
		[Vector3(20,2.24,-170),"administration return"],
		[Vector3(20,2.24,-98),"mall return"],
		[Vector3(0,2.24,-98),"crosswalk return"],
		[Vector3(0,2.24,-54),"stair top return"],
		[Vector3(0,0,-39),"broad stair descent"],
		[Vector3(0,0,-16),"gate court return"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"no_teleport_within_fixture":true,"build_ms":world.built_ms,"version":world.data.version,"scope":"East Gate ground, continuous side ramp, inner link and A-B walk interface; ramp dimensions/placement fitted; not whole-zone acceptance"}
	FileAccess.open("res://tests/artifacts/east_gate_ground_v38.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("EAST_GATE_GROUND ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
