extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="start-public-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("le-tian",Vector3(8,8,-620),Vector3(46,10,-652))
	await capture("le-tian-entry",Vector3(33,4.2,-643),Vector3(48,4,-658))
	await capture("zhi-ren",Vector3(15,12,-759),Vector3(57,10,-734))
	await capture("zhi-ren-arcade",Vector3(49,4.1,-745),Vector3(64,5,-737))
	await capture("zhi-xin",Vector3(-52,9,-694),Vector3(-115,9,-733))
	await capture("library-corner",Vector3(-87,4.3,-715),Vector3(-105,5.9,-697))
	await capture("cheng-dao",Vector3(9,9,-613),Vector3(-32,11,-646))
	await capture("dao-yuan",Vector3(-5,7,-785),Vector3(-65,9,-805))
	await fixture(Vector3(28,2.54,-652),[
		[Vector3(46,2.24,-652),"Le Tian entrance"],[Vector3(55,2.24,-652),"Le Tian recessed lobby"],
		[Vector3(46,2.24,-652),"Le Tian lobby return"],[Vector3(28,2.24,-652),"Le Tian forecourt"]])
	await fixture(Vector3(30,2.54,-734),[
		[Vector3(57,2.24,-734),"Zhiren open arcade"],[Vector3(67,2.24,-734),"Zhiren recessed room"],
		[Vector3(57,2.24,-734),"Zhiren room return"],[Vector3(30,2.24,-734),"Zhiren forecourt"]])
	await fixture(Vector3(-74,2.54,-733),[
		[Vector3(-110,2.24,-733),"Zhi Xin flag court bypass"],[Vector3(-130,2.24,-733),"Zhi Xin library entrance"],
		[Vector3(-110,2.24,-733),"Zhi Xin library return"],
		[Vector3(-110,2.24,-702),"library return wing door"],[Vector3(-103,2.24,-702),"return wing public room"],
		[Vector3(-110,2.24,-702),"return wing door exit"],[Vector3(-110,2.24,-733),"court return"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":3,"build_ms":world.built_ms,"no_teleport_within_each_fixture":true,"scope":"five start-zone facade families; three changed ground entrances, library return glazing and flag-court bypass"}
	FileAccess.open("res://tests/artifacts/start_zone_public_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("START_PUBLIC ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
