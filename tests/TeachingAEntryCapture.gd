extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="teaching-a-entry-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("long-hall",Vector3(-47,4.1,-99),Vector3(-50,6.3,-128))
	await capture("glazed-entry",Vector3(-43,4.2,-115),Vector3(-56,6.0,-115))
	await capture("outer-screen",Vector3(-49,4.2,-122),Vector3(-32,7,-125))
	await capture("court",Vector3(-69,5,-115),Vector3(-53,12,-103))
	await capture("front",Vector3(-17,15,-80),Vector3(-61,13,-113))
	await fixture(Vector3(-34,2.54,-115),[
		[Vector3(-48,2.24,-115),"tall arcade entrance approach"],[Vector3(-61,2.24,-115),"glass doorway and inner hall"],
		[Vector3(-67,2.24,-115),"inner hall opens to court"],[Vector3(-73.4,2.24,-98.72),"retained switchback foot"],
		[Vector3(-55,7.165,-98.72),"first flight and retained lower gallery"],[Vector3(-55,7.165,-102.72),"first landing transfer"],
		[Vector3(-73,10.865,-102.72),"return flight to upper gallery"],[Vector3(-74,10.865,-106.92),"upper landing"],
		[Vector3(-52,10.865,-106.92),"upper gallery meets raised arcade wing"],[Vector3(-74,10.865,-106.92),"upper gallery return"],
		[Vector3(-74,10.865,-102.72),"return flight head"],[Vector3(-55,7.165,-102.72),"return flight descent"],
		[Vector3(-55,7.165,-98.72),"lower landing return"],[Vector3(-74,2.24,-98.72),"first flight descent"],
		[Vector3(-67,2.24,-115),"court return"],[Vector3(-34,2.24,-115),"inner hall and entrance exit"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"build_ms":world.built_ms,"no_teleport_within_each_fixture":true,"scope":"Rebuilt TA tall arcade and glass entry, retained lower gallery, switchback and upper-wing connection; unrelated buildings not retested"}
	FileAccess.open("res://tests/artifacts/teaching_a_entry_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TEACHING_A_ENTRY ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
