extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="student-public-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("front",Vector3(-8,15,-366),Vector3(68,13,-400))
	await capture("courts",Vector3(4,66,-350),Vector3(72,12,-400))
	await capture("portal",Vector3(40,4.1,-393),Vector3(86,6,-389))
	await capture("yellow-arcade",Vector3(59,4.05,-379.5),Vector3(85,4.1,-378))
	await capture("dining-room",Vector3(69,4.0,-430),Vector3(78,4,-429))
	await capture("upper-gallery",Vector3(61,8.3,-381),Vector3(84,8.1,-381))
	await capture("red-wall",Vector3(71,4.2,-390),Vector3(88,6.5,-387))
	await fixture(Vector3(40,2.54,-392),[
		[Vector3(60,2.24,-392),"main portal"],[Vector3(76,2.24,-392),"ground court"],
		[Vector3(76,2.24,-380),"canteen arcade aisle"],[Vector3(75,2.24,-372),"right canteen doorway"],
		[Vector3(71,2.24,-370),"right dining bay"],[Vector3(75,2.24,-372),"right canteen return"],
		[Vector3(75,2.24,-380),"arcade return"],[Vector3(76,2.24,-387),"rear hall approach"],
		[Vector3(91,2.24,-387),"red rear door"],[Vector3(76,2.24,-387),"rear hall return"]])
	await fixture(Vector3(69,2.54,-418),[
		[Vector3(69,2.24,-428),"left canteen doorway"],[Vector3(74,2.24,-430),"left dining aisle"],
		[Vector3(69,2.24,-428),"left dining return"],[Vector3(69,2.24,-418),"left arcade return"]])
	await fixture(Vector3(58,2.54,-408),[
		[Vector3(76,6.64,-408),"student stair ascent"],[Vector3(78,6.64,-418),"new left upper gallery"],
		[Vector3(59,6.64,-418),"left upper court edge"],[Vector3(78,6.64,-418),"left gallery return"],
		[Vector3(78,6.64,-382),"transverse upper landing"],[Vector3(56,6.64,-382),"pond gallery turn"],
		[Vector3(56,6.64,-360),"student to covered bridge"],
		[Vector3(56,6.64,-382),"upper bridge return"],[Vector3(78,6.64,-382),"right gallery return"],
		[Vector3(78,6.64,-408),"stair landing return"],[Vector3(58,2.24,-408),"student stair descent"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":3,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"student ground arcades, dining doors, rear portal wall, widened upper galleries and retained library bridge connection"}
	FileAccess.open("res://tests/artifacts/student_public_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("STUDENT_PUBLIC ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
