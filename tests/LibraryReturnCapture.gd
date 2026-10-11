extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="library-return-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("pond-elevation",Vector3(116,5.2,-361),Vector3(81,13,-320))
	await capture("pond-corner",Vector3(61,5.2,-353),Vector3(88,13,-324))
	await capture("upper-gallery",Vector3(70,8.2,-326.8),Vector3(97,8,-326.8))
	await capture("front",Vector3(2,12,-237),Vector3(78,14,-290))
	await capture("roof",Vector3(129,57,-363),Vector3(80,16,-292))
	await capture("quay",Vector3(102,4.2,-347),Vector3(85,8,-325))
	await fixture(Vector3(56,6.94,-340),[
		[Vector3(56,6.64,-330),"upper covered bridge"],
		[Vector3(61,6.64,-330),"library corner threshold"],
		[Vector3(66,6.64,-326.8),"inset upper gallery transfer"],
		[Vector3(88,6.64,-326.8),"gallery behind return facade"],
		[Vector3(88,6.64,-302),"transverse gallery"],
		[Vector3(88,6.64,-290),"main upper foyer"]])
	await fixture(Vector3(95,2.57,-340),[
		[Vector3(95,2.24,-334.5),"quay to pond frontage"],
		[Vector3(95,2.24,-326),"new pond-side recessed entrance"],
		[Vector3(95,2.27,-340),"pond entrance return"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":2,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"curved library side envelope, adjusted 2F gallery and pond entrance; prior unrelated routes reused"}
	FileAccess.open("res://tests/artifacts/library_return_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_RETURN ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
