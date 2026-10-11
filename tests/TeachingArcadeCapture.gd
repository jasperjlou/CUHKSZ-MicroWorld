extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="teaching-arcade-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("c-long-hall",Vector3(-47,4,-304),Vector3(-47,6,-344))
	await capture("c-reverse",Vector3(-46,4,-340),Vector3(-47,6,-302))
	await capture("c-portal",Vector3(-44,4,-325),Vector3(-59,4,-325))
	await capture("c-canopy",Vector3(-17,13,-294),Vector3(-53,9,-325))
	await capture("c-court",Vector3(-70,9,-317),Vector3(-49,8,-327))
	await capture("b-lobby",Vector3(-43,4,-207),Vector3(-63,4,-207))
	await capture("b-corridor",Vector3(-53,4,-207),Vector3(-74,4,-207))
	await fixture(Vector3(-30,2.54,-325),[
		[Vector3(-48,2.24,-325),"C high arcade approach"],[Vector3(-58,2.24,-325),"C entrance corridor"],
		[Vector3(-70,2.24,-325),"C corridor to court"],[Vector3(-58,2.24,-325),"C corridor return"],
		[Vector3(-47,2.24,-325),"C entrance exit"],[Vector3(-47,2.24,-303),"C tall arcade north end"],
		[Vector3(-47,2.24,-344),"C tall arcade lengthwise"]])
	await fixture(Vector3(-73.4,2.54,-305.56),[
		[Vector3(-55.5,7.165,-305.56),"C retained stair ascent"],[Vector3(-53.8,7.165,-313),"C narrowed upper gallery"],
		[Vector3(-55.5,7.165,-305.56),"C upper gallery return"],[Vector3(-73.4,2.24,-305.56),"C stair descent"]])
	await fixture(Vector3(-38,2.54,-207),[
		[Vector3(-47.5,2.24,-207),"B transparent entrance"],[Vector3(-59,2.24,-207),"B lobby to new corridor"],
		[Vector3(-70,2.24,-207),"B extended corridor"],[Vector3(-74.5,2.24,-207),"B corridor rear opening"],
		[Vector3(-59,2.24,-207),"B corridor return"],[Vector3(-38,2.24,-207),"B entrance return"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":3,"build_ms":world.built_ms,"no_teleport_within_each_fixture":true,"scope":"C high arcade, inner corridor and retained 2F stair; B extended lobby corridor"}
	FileAccess.open("res://tests/artifacts/teaching_arcade_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TEACHING_ARCADE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
