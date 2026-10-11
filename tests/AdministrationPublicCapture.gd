extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="admin-public-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("front",Vector3(9,12,-148),Vector3(76,17,-185))
	await capture("forecourt",Vector3(33,4,-191),Vector3(60,8,-168))
	await capture("ground-entry",Vector3(43,4,-149.93),Vector3(60,4,-149.93))
	await capture("lobby",Vector3(53,4,-149.93),Vector3(66,4,-145.5))
	await capture("stair-bridge",Vector3(54,5,-180),Vector3(87,17,-180))
	await capture("rear-garden",Vector3(105,16.5,-180),Vector3(115,16.5,-196))
	await fixture(Vector3(35,2.54,-150.07),[
		[Vector3(49,2.24,-150.07),"first wing recessed doorway"],[Vector3(61,2.24,-150.07),"first wing public lobby"],
		[Vector3(49,2.24,-150.07),"first wing lobby return"],[Vector3(35,2.24,-150.07),"first wing forecourt return"]])
	await fixture(Vector3(35,2.54,-209.93),[
		[Vector3(49,2.24,-209.93),"second wing recessed doorway"],[Vector3(61,2.24,-209.93),"second wing public lobby"],
		[Vector3(49,2.24,-209.93),"second wing lobby return"],[Vector3(35,2.24,-209.93),"second wing forecourt return"]])
	await fixture(Vector3(36,2.54,-180),[
		[Vector3(56,2.24,-180),"forecourt flowerbed centre opening"],[Vector3(75,6.64,-180),"retained broad stair first landing"],
		[Vector3(95,11.04,-180),"retained broad stair second landing"],[Vector3(112,14.64,-180),"rear terrace centre"],
		[Vector3(112,14.64,-166),"rear planted terrace aisle"],[Vector3(96,14.64,-166),"rear aisle clear of planter"],
		[Vector3(96,14.64,-180),"rear landing return"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":3,"build_ms":world.built_ms,"no_teleport_within_each_fixture":true,"scope":"two recessed ground lobbies, planted forecourt and rear terrace access"}
	FileAccess.open("res://tests/artifacts/administration_public_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ADMINISTRATION_PUBLIC ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
