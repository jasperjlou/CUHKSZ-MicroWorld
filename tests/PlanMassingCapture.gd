extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(15);await RenderingServer.frame_post_draw
	var filename:="plan-refined-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("teaching-plan",Vector3(-34,180,-309),Vector3(-65,0,-310))
	await capture("c-oblique",Vector3(-13,43,-283),Vector3(-65,12,-325))
	await capture("b-court",Vector3(-65,5,-220),Vector3(-59,12,-239))
	await capture("a-arcade",Vector3(-45,4,-102),Vector3(-51,4,-130))
	await capture("administration-front",Vector3(3,13,-137),Vector3(74,16,-180))
	await capture("administration-back",Vector3(125,23,-154),Vector3(95,22,-180))
	await capture("administration-terrace",Vector3(111,16.4,-166),Vector3(91,16.7,-181))
	await fixture(Vector3(51,2.54,-180),[
		[Vector3(75,6.64,-180),"admin first landing"],[Vector3(95,11.04,-180),"admin second landing"],
		[Vector3(112,14.64,-180),"admin third flight and 4F terrace"],
		[Vector3(112,14.64,-166),"admin terrace side return"],[Vector3(96,14.64,-166),"admin upper side aisle"],
		[Vector3(96,14.64,-180),"admin backdoor approach"],[Vector3(91,14.64,-180),"admin 4F glazed doorway"],
		[Vector3(96,14.64,-180),"admin backdoor return"],[Vector3(96,14.64,-166),"admin side aisle return"],
		[Vector3(112,14.64,-166),"admin rear terrace return"],[Vector3(112,14.64,-180),"admin third flight head"],
		[Vector3(95,11.04,-180),"admin third flight descent"],[Vector3(55,2.24,-180),"admin full stair descent"]])
	await fixture(Vector3(-32,2.54,-115),[[Vector3(-68,2.24,-115),"TA new arcade doorway"],[Vector3(-32,2.24,-115),"TA doorway return"]])
	await fixture(Vector3(-38,2.54,-207),[[Vector3(-47.5,2.24,-207),"TB retained lobby"],[Vector3(-38,2.24,-207),"TB lobby return"]])
	await fixture(Vector3(-32,2.54,-325),[[Vector3(-69,2.24,-325),"TC oblique court passage"],[Vector3(-32,2.24,-325),"TC court return"]])
	await fixture(Vector3(-32,2.54,-420),[[Vector3(-77,2.24,-420),"TD oblique court and service entrance"],[Vector3(-32,2.24,-420),"TD court return"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":5,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"plan-based B/C/D masses and admin upper body/4F terrace; unchanged library and student centre were not retested"}
	FileAccess.open("res://tests/artifacts/plan_massing_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("PLAN_MASSING ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
