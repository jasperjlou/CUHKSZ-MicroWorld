extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="library-lobby-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("g-room",Vector3(85,4.1,-279),Vector3(93,4,-297))
	await capture("g-glazing",Vector3(85,4,-290),Vector3(84,4,-272))
	await capture("g-collaboration",Vector3(87,4,-289),Vector3(94,3.4,-298))
	await capture("stair-seating",Vector3(64,4.2,-295),Vector3(80,7.5,-281))
	await capture("upper-blades",Vector3(82,8.3,-297),Vector3(90,8,-280))
	await fixture(Vector3(86,2.54,-272),[
		[Vector3(86,2.24,-290),"G glazed side entrance to central aisle"],[Vector3(86,2.24,-299),"G shared-room cross aisle"],
		[Vector3(86,2.24,-290),"G reading-room return"],[Vector3(86,2.24,-272),"G side entrance exit"]])
	await fixture(Vector3(66,2.54,-290),[
		[Vector3(80,6.64,-290),"normal stair remains walkable"],[Vector3(88,6.64,-290),"2F foyer approach"],
		[Vector3(88,6.64,-282),"2F seating-side aisle"],[Vector3(79.2,6.64,-282),"deep seating top row from upper landing"],
		[Vector3(88,6.64,-282),"seating top row return"],[Vector3(95,6.64,-282),"3F stair foot"],
		[Vector3(81,11.04,-282),"3F stair ceiling void preserved"],[Vector3(95,6.64,-282),"3F stair descent"],
		[Vector3(88,6.64,-282),"2F stair return aisle"],[Vector3(88,6.64,-290),"2F foyer return"],
		[Vector3(80,6.64,-290),"normal stair landing return"],[Vector3(66,2.24,-290),"normal stair descent"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":2,"build_ms":world.built_ms,"no_teleport_within_each_fixture":true,"scope":"G glass room and shared aisle, normal 2F stair, top seating-row access, 3F ceiling void; deep seating intentionally not a ramp"}
	FileAccess.open("res://tests/artifacts/library_lobby_detail_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_LOBBY_DETAIL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
