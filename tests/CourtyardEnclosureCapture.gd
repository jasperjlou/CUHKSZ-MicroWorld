extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="courtyard-enclosure-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("whole",Vector3(-15,38,-360),Vector3(49,4,-360))
	await capture("lower-arcade",Vector3(37,.15,-349),Vector3(47,.1,-370))
	await capture("lower-room",Vector3(50.5,.1,-368),Vector3(46,.2,-350))
	await capture("seating",Vector3(32,.2,-360),Vector3(35,3,-339))
	await capture("north-gallery",Vector3(13,8.3,-331),Vector3(56,8,-331))
	await capture("student-gallery",Vector3(20,8.3,-400),Vector3(76,8,-400))
	await fixture(Vector3(32,2.54,-330),[
		[Vector3(32,-1.76,-353),"retained north stair descent"],[Vector3(38,-1.76,-355),"east lower aisle"],
		[Vector3(44.5,-1.76,-366.8),"covered lower arcade"],[Vector3(51,-1.76,-366.8),"new lower doorway"],
		[Vector3(51,-1.76,-353.2),"occupied lower room"],[Vector3(44.5,-1.76,-353.2),"second lower doorway"],
		[Vector3(38,-1.76,-353.2),"return east aisle"],[Vector3(32,-1.76,-353),"north stair foot"],
		[Vector3(32,2.24,-330),"north stair ascent under gallery"]])
	await fixture(Vector3(15,2.54,-385),[[Vector3(15,-1.76,-350),"retained west ramp descent"],[Vector3(15,2.24,-385),"retained west ramp return"]])
	await fixture(Vector3(78,6.94,-408),[
		[Vector3(78,6.64,-400),"student upper transfer"],[Vector3(13,6.64,-400),"new student-side gallery"],
		[Vector3(78,6.64,-400),"student-side gallery return"],[Vector3(78,6.64,-382),"existing student gallery"],
		[Vector3(56,6.64,-382),"student side opening"],[Vector3(56,6.64,-331),"extended back gallery"],
		[Vector3(13,6.64,-331),"new library-side gallery"],[Vector3(56,6.64,-331),"library-side gallery return"],
		[Vector3(61,6.64,-330),"existing library threshold"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":3,"build_ms":world.built_ms,"no_teleport_within_each_fixture":true,"scope":"New three-sided gallery enclosure and lower rooms; retained north stairs/west ramp and student/library threshold connections"}
	FileAccess.open("res://tests/artifacts/courtyard_enclosure_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("COURTYARD_ENCLOSURE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
