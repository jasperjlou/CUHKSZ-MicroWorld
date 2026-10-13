extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-exterior-v192-final-outward",Vector3(29,1.8,44),Vector3(29,3,98))
	await capture("gate-exterior-v192-final-neck",Vector3(18,1.8,38),Vector3(28,.2,57))
	await fixture(Vector3(21,.4,37),[
		[Vector3(21,.112,55),"sidewalk neck outward"],
		[Vector3(48,.112,55),"striped vehicle mouth"],
		[Vector3(21,.112,55),"vehicle mouth return"],
		[Vector3(21,world.builder.height(21,37),37),"neck return"]])
	await fixture(Vector3(29,.4,40),[
		[Vector3(29,.112,64),"vehicle neck to road"],
		[Vector3(29,0,40),"vehicle neck return"]])
	FileAccess.open("res://tests/artifacts/east_gate_exterior_seams_v192.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":2,"scope":"Repaired entry seam and vehicle mouth only;retain original report with failed initial seam"},"\t"))
	quit(0 if failures.is_empty() else 1)
