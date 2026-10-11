extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(15);await RenderingServer.frame_post_draw
	var filename:="conference-refined-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("entrance",Vector3(20,12,-76),Vector3(56,15,-80))
	await capture("massing",Vector3(6,40,-133),Vector3(68,15,-88))
	await capture("foyer",Vector3(47,8.2,-75),Vector3(59,12,-87))
	await capture("lobby-glass",Vector3(56,8.3,-82),Vector3(42,11,-82))
	await capture("lower-arcade",Vector3(57,4,-113),Vector3(61,4,-66))
	await capture("mezzanine",Vector3(57,12.7,-77),Vector3(46,8,-85))
	await fixture(Vector3(20,2.54,-80),[
		[Vector3(27,2.24,-80),"ICC exterior stair foot"],
		[Vector3(39,6.64,-80),"ICC raised entrance terrace"],
		[Vector3(49,6.64,-80),"ICC open glazed doorway"],
		[Vector3(44,6.64,-91),"ICC foyer stair foot"],
		[Vector3(56,11.04,-91),"ICC mezzanine stair ascent"],
		[Vector3(58,11.04,-80),"ICC mezzanine gallery"],
		[Vector3(56,11.04,-91),"ICC mezzanine return"],
		[Vector3(44,6.64,-91),"ICC interior stair descent"],
		[Vector3(49,6.64,-80),"ICC foyer return"],
		[Vector3(39,6.64,-80),"ICC terrace return"],
		[Vector3(23,2.24,-80),"ICC outside stair descent"]])
	await fixture(Vector3(48,2.54,-111),[
		[Vector3(60,2.24,-111),"ICC lower arcade approach"],
		[Vector3(60,2.24,-70),"ICC lower arcade passage"],
		[Vector3(60,2.24,-111),"ICC lower arcade return"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":2,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"new ICC exterior stair, foyer, mezzanine and lower arcade; no auditorium seating or full room plan claimed"}
	FileAccess.open("res://tests/artifacts/conference_centre_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("CONFERENCE_CENTRE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
