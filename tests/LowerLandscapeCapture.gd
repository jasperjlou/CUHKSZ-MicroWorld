extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="landscape-refined-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("south-gate",Vector3(-181,5.7,-146),Vector3(-152,3.4,-169))
	await capture("gate-avenue",Vector3(-142,5.6,-167),Vector3(-45,5,-167))
	await capture("pond-student",Vector3(116,5,-337),Vector3(72,9,-379))
	await capture("pond-library",Vector3(116,4.5,-361),Vector3(78,13,-313))
	await capture("pond-quay",Vector3(103,3.9,-334),Vector3(91,2.1,-350))
	await capture("central-water-court",Vector3(161,61,-363),Vector3(78,8,-354))
	await fixture(Vector3(-181,2.54,-178),[
		[Vector3(-147,2.24,-178),"south gate side opening"],
		[Vector3(-139,2.24,-167),"south gate avenue merge"],
		[Vector3(-30,2.24,-167),"teaching A/B avenue"],
		[Vector3(0,2.24,-167),"avenue central mall link"]])
	await fixture(Vector3(130,2.54,-380),[
		[Vector3(123,2.24,-373),"pond east approach"],
		[Vector3(123,2.24,-332),"pond east bank"],
		[Vector3(95,2.24,-334.5),"library pond quay approach"],
		[Vector3(95,2.27,-340),"curved quay standing surface"],
		[Vector3(95,2.24,-334.5),"quay return"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":2,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"new south gate avenue and corrected lotus pond shore; previous building checks reused"}
	FileAccess.open("res://tests/artifacts/lower_landscape_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LOWER_LANDSCAPE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
