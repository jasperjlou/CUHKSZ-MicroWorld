extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-exterior-v192-outward",Vector3(29,1.8,44),Vector3(29,3,98))
	await capture("gate-exterior-v192-sidewalk",Vector3(38,1.8,55),Vector3(-90,1.7,56))
	await capture("gate-exterior-v192-return",Vector3(29,1.8,88),Vector3(1,7,-26))
	await fixture(Vector3(21,.4,37),[
		[Vector3(21,.112,55),"sidewalk neck outward"],
		[Vector3(48,.112,55),"striped vehicle mouth"],
		[Vector3(21,.112,55),"vehicle mouth return"],
		[Vector3(21,world.builder.height(21,37),37),"neck return"]])
	await fixture(Vector3(29,.4,54),[
		[Vector3(29,.112,87),"street to opposite pavement"],
		[Vector3(-30,.112,87),"opposite sidewalk"],
		[Vector3(29,.112,87),"opposite return"],
		[Vector3(29,.112,54),"vehicle throat return"]])
	FileAccess.open("res://tests/artifacts/east_gate_exterior_v192.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":2,"scope":"East Gate exterior paving/grade connections only;source capture date and dimensions unknown;no whole-campus acceptance"},"\t"))
	quit(0 if failures.is_empty() else 1)
