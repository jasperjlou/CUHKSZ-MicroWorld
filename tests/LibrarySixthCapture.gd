extends "res://tests/LibraryLowerLevelCapture.gd"
const Core := preload("res://world/visual_campus/LibraryServiceCores.gd")
const Plan := preload("res://world/visual_campus/LibraryUpperLevels.gd")
func cp(x: float,y: float,z: float) -> Vector3:
	var p:=Core.local_point(1,Vector3(x,y,z));return wp(p.x,p.y,p.z)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-sixth-atrium-v47",wp(-12,22.5,-5),wp(16,22.5,3))
	await capture("library-sixth-study-v47",wp(14.8,22.5,-9),wp(29,22,-5))
	await capture("library-sixth-rooms-v47",wp(26,22.5,-9),wp(23,22,5))
	await capture("library-fifth-rare-v47",wp(-20.5,18.5,21.2),wp(-27,18,26))
	await capture("library-fifth-silence-v47",wp(24,18.5,-10),wp(26,18.2,-18))
	await capture("library-section-front-v47",wp(-8,38,72),wp(0,14,5))
	await capture("library-six-level-atrium-v47",wp(9,10.6,10),wp(-12,19,1))
	await fixture(wp(9,17.1,13.5),[
		[wp(-12,16.8,13.5),"fifth gallery to new public foot"],
		[wp(-12,20.8,-5.4),"public sixth floor ascent"],
		[wp(14.5,20.8,-5.4),"sixth bridge into retained wing"],
		[wp(14.5,20.8,-9),"sixth rear aisle approach"],
		[wp(26,20.8,-10),"sixth room cluster cross aisle"],
		[wp(26,20.8,-2),"sixth central study aisle"],
		[wp(26,20.8,6),"sixth front room cluster aisle"],
		[wp(26,20.8,-10),"sixth cluster return"],
		[wp(14.5,20.8,-9),"sixth rear aisle return"],
		[wp(14.5,20.8,14),"sixth wing to front gallery"],
		[wp(5,20.8,14),"sixth front bridge"],
		[cp(6,20.8,-3.8),"sixth diagonal core approach"],
		[cp(1.45,20.8,-3.8),"sixth diagonal core door"],
		[cp(1.45,18.8,3.8),"sixth core descending flight"],
		[cp(-1.45,18.8,3.8),"sixth core half landing turn"],
		[cp(-1.45,16.8,-3.8),"sixth core down to fifth"],
		[cp(6,16.8,-3.8),"fifth core exit retained"]])
	await fixture(cp(6,17.1,-3.8),[
		[cp(0,16.8,-3.8),"fifth core ascent approach"],
		[cp(-1.45,16.8,-3),"fifth fire stair foot"],
		[cp(-1.45,18.8,3.8),"sixth core ascending flight"],
		[cp(1.45,18.8,3.8),"sixth core ascending turn"],
		[cp(1.45,20.8,-3.8),"sixth core upper arrival"],
		[cp(6,20.8,-3.8),"sixth side doorway"],
		[wp(5,20.8,14),"sixth core to front bridge"],
		[wp(14.5,20.8,14),"sixth core to wing"],
		[wp(14.5,20.8,-5.4),"sixth return alongside atrium"],
		[wp(-12,20.8,-5.4),"sixth bridge to public stair"],
		[wp(-12,16.8,13.5),"public sixth floor descent"]])
	await fixture(wp(-20,17.1,12.9),[
		[wp(-20.5,16.8,21),"rare book room approach beside core"],
		[wp(-20.5,16.8,23.4),"rare book room doorway"],
		[wp(-27,16.8,23.5),"rare book reading interior"],
		[wp(-20.5,16.8,23.4),"rare book interior return"],
		[wp(-20.5,16.8,21),"rare book room exit"],
		[wp(-20,16.8,12.9),"rare book to fifth gallery"]])
	await fixture(wp(-18,.3,34),[[wp(-18,0,20),"revised lower front doorway"],[wp(-18,0,-8),"lower study aisle retained"],[wp(-18,0,34),"revised lower front exit"]])
	await fixture(wp(5,.3,31),[[wp(17,4.4,18),"outdoor main stair retained"],[wp(18,4.4,10),"second floor main portal retained"],[wp(17,4.4,18),"second portal return"],[wp(5,0,30),"outdoor stair descent retained"]])
	var minimum_clearance:=100.0
	for point: Vector2 in [Vector2(15,-5),Vector2(30,-15),Vector2(30,3),Vector2(-6,23)]:minimum_clearance=minf(minimum_clearance,Plan.roof_y(point,86,58)-20.8)
	if minimum_clearance<2.5:failures.append("sixth floor roof clearance")
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":5,"no_teleport_within_each_fixture":true,"minimum_sample_roof_clearance":minimum_clearance,"build_ms":world.built_ms,"scope":"Reduced6F public stair/core/aisles,5F rare-book door and frontage affected by plan/section correction. Not all room interiors or surveyed geometry."}
	FileAccess.open("res://tests/artifacts/library_sixth_v47.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_SIXTH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
