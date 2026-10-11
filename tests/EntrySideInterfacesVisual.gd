extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("icc-avenue-v39",Vector3(56,4.0,-112),Vector3(63,4.4,-76))
	await capture("icc-door-bays-v39",Vector3(55,4.0,-99),Vector3(64,4.0,-99))
	await capture("icc-gate-side-grade-v39",Vector3(30,8,-43),Vector3(53,3,-50))
	await fixture(Vector3(27.8,world.builder.height(27.8,-47)+.3,-47),[
		[Vector3(27.8,2.24,-60),"new short return onto gate upper landing"],
		[Vector3(27.8,world.builder.height(27.8,-47),-47),"new short return down to ICC side path"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"no_teleport_within_fixture":true,"build_ms":world.built_ms,"scope":"Final panel material/front fade and two newly added gate-apron return legs only. Earlier 22 verified legs unchanged and not repeated."}
	FileAccess.open("res://tests/artifacts/entry_side_interfaces_visual_v39.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ENTRY_SIDE_VISUAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
