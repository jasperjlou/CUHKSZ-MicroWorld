extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="library-plan-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("roof",Vector3(-5,66,-357),Vector3(84,14,-290))
	await capture("rear-wings",Vector3(159,44,-320),Vector3(91,17,-286))
	await capture("front",Vector3(2,12,-237),Vector3(78,14,-290))
	await capture("pond",Vector3(116,5.2,-361),Vector3(81,13,-320))
	await capture("terrace",Vector3(106,13,-306),Vector3(88,14,-292))
	await capture("study",Vector3(79,12.7,-282),Vector3(83,12.1,-310))
	await capture("stair",Vector3(96,8.3,-282),Vector3(81,11.6,-282))
	# New levels are reached through ordinary character movement from the retained 2F foyer.
	await fixture(Vector3(88,6.94,-290),[
		[Vector3(95.6,6.64,-290),"2F foyer rear aisle"],
		[Vector3(95.6,6.64,-282),"3F stair foot"],
		[Vector3(79.8,11.04,-282),"3F stair ascent"],
		[Vector3(76,11.04,-282),"3F landing"],
		[Vector3(76,11.04,-300),"3F transverse reading aisle"],
		[Vector3(83,11.04,-300),"3F rear study approach"],
		[Vector3(91,11.04,-300),"3F terrace doorway"],
		[Vector3(97,11.04,-303),"3F outdoor study terrace"],
		[Vector3(91,11.04,-300),"terrace return"],
		[Vector3(83,11.04,-300),"study return"],
		[Vector3(76,11.04,-300),"landing aisle return"],
		[Vector3(76,11.04,-282),"3F stair head"],
		[Vector3(95.6,6.64,-282),"3F stair descent"]])
	await fixture(Vector3(56,6.94,-340),[
		[Vector3(56,6.64,-330),"covered bridge"],[Vector3(61,6.64,-330),"library corner"],
		[Vector3(66,6.64,-326.8),"upper gallery transfer"],[Vector3(88,6.64,-326.8),"retained pond gallery"],
		[Vector3(88,6.64,-302),"retained transverse gallery"],[Vector3(88,6.64,-290),"retained foyer"]])
	await fixture(Vector3(95,2.57,-340),[
		[Vector3(95,2.24,-334.5),"pond frontage approach"],[Vector3(95,2.24,-326),"pond-side G entry"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":3,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"source-plan library roof/rear wings, new 3F access and retained 2F/pond entrances; other routes reused"}
	FileAccess.open("res://tests/artifacts/library_plan_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_PLAN ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
