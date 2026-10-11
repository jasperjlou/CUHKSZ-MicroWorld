extends "res://tests/LowerCampusScopeReview.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("east-gate",Vector3(0,13,72),Vector3(0,12,-16))
	await capture("east-gate-entry",Vector3(-5,2.2,21),Vector3(8,10,-19))
	await capture("east-gate-inside",Vector3(0,13,-70),Vector3(0,12,-16))
	await capture("lee_yin_yee",Vector3(-177,26,-492),Vector3(-120,12,-530))
	await capture("cheng_dao",Vector3(0,18,-605),Vector3(-32,10,-646))
	await capture("le_tian",Vector3(-1,18,-606),Vector3(46,12,-652))
	await capture("track",Vector3(-140,75,-1120),Vector3(-14,2,-1018))
	await fixture(Vector3(0,.3,20),[
		[Vector3(0,0,-18),"east origin and overhead passage"],
		[Vector3(0,0,-39),"inner overhead passage"],
		[Vector3(0,0,-18),"gate inner return"],
		[Vector3(0,0,20),"gate street return"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"build_ms":world.built_ms,"version":world.data.version,"scope":"East Gate shell and targeted unobstructed inventory views. Four affected origin-passage legs only; district movement evidence reused."}
	FileAccess.open("res://tests/artifacts/east_gate_scope_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("EAST_GATE_SCOPE_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
