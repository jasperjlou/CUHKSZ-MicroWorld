extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="teaching-refined-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("a-front",Vector3(-7,12,-85),Vector3(-65,13,-115))
	await capture("a-court",Vector3(-71,8,-115),Vector3(-55,13,-109))
	await capture("a-switchback",Vector3(-65,6,-122),Vector3(-64,10,-100))
	await capture("b-front",Vector3(-18,9,-181),Vector3(-65,13,-220))
	await capture("b-lobby",Vector3(-43,4,-207),Vector3(-49,4,-207))
	await capture("c-arcade",Vector3(-44,4,-304),Vector3(-47,4,-348))
	await capture("c-entry",Vector3(-46,4,-325),Vector3(-59,4,-325))
	await capture("d-front",Vector3(-15,11,-390),Vector3(-66,11,-420))
	await capture("group",Vector3(3,22,-83),Vector3(-50,12,-280))
	await fixture(Vector3(-30,2.54,-115),[
		[Vector3(-66,2.24,-115),"TA courtyard entrance"],
		[Vector3(-73.4,2.24,-98.72),"TA stair foot"],
		[Vector3(-55,7.165,-98.72),"TA first landing"],
		[Vector3(-55,7.165,-102.72),"TA switchback transfer"],
		[Vector3(-73,10.865,-102.72),"TA return flight ascent"],
		[Vector3(-74,10.865,-106.92),"TA upper transverse landing"],
		[Vector3(-52,10.865,-106.92),"TA upper open gallery"],
		[Vector3(-74,10.865,-106.92),"TA gallery return"],
		[Vector3(-74,10.865,-102.72),"TA return flight head"],
		[Vector3(-55,7.165,-102.72),"TA return flight descent"]])
	await fixture(Vector3(-38,2.54,-207),[
		[Vector3(-45,2.24,-207),"TB lobby doorway"],
		[Vector3(-47.5,2.24,-207),"TB lobby interior"],
		[Vector3(-38,2.24,-207),"TB lobby return"]])
	await fixture(Vector3(-30,2.54,-325),[
		[Vector3(-48,2.24,-325),"TC screened arcade"],
		[Vector3(-57,2.24,-325),"TC glazed entrance"],
		[Vector3(-30,2.24,-325),"TC entrance return"]])
	await fixture(Vector3(-28,2.54,-420),[
		[Vector3(-64,2.24,-420),"TD courtyard entrance"],
		[Vector3(-78,2.24,-420),"TD service doors"],
		[Vector3(-28,2.24,-420),"TD entrance return"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":4,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"TA upper access, TB lobby, TC arcade and TD public ground floor"}
	FileAccess.open("res://tests/artifacts/teaching_refinement_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TEACHING_REFINEMENT ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
