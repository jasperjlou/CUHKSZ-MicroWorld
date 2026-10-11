extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-square-v38",Vector3(-2,3.0,-16),Vector3(0,6,-55))
	await capture("gate-ramp-v38",Vector3(13,5,-29),Vector3(17.0,2,-51))
	await capture("gate-landing-v38",Vector3(-30,25,-54),Vector3(2,2,-74))
	await fixture(Vector3(17,.3,-34),[
		[Vector3(17,2.24,-65),"final ramp centre ascent"],
		[Vector3(18.05,2.24,-65),"ramp outer landing"],
		[Vector3(18.05,0,-34),"outer clearance past bridge column"],
		[Vector3(15.95,0,-34),"ramp inner landing"],
		[Vector3(15.95,2.24,-65),"inner clearance by stair cheek"],
		[Vector3(20,2.24,-70),"ramp exit to upper stone field"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"no_teleport_within_fixture":true,"build_ms":world.built_ms,"version":world.data.version,"scope":"Final 3 m fitted ramp shifted clear of bridge column; centre and both edges. Reuse unaffected 11 main-route legs from initial V38; initial 5 ramp-related legs superseded."}
	FileAccess.open("res://tests/artifacts/east_gate_ramp_finish_v38.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("GATE_RAMP_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
