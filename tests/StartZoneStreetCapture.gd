extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="start-street-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("avenue",Vector3(6.2,4,-748),Vector3(0,5,-666))
	await capture("le-tian-court",Vector3(14,4,-632),Vector3(44,6,-660))
	await capture("main-square",Vector3(-13,6,-748),Vector3(-102,9,-732))
	await capture("zhi-ren-court",Vector3(10,5,-748),Vector3(59,7,-734))
	await capture("dao-yuan",Vector3(-9,4.3,-817),Vector3(-60,8,-805))
	await capture("old-gate-connection",Vector3(-104,7,-826),Vector3(-125,5,-860))
	await capture("district",Vector3(-145,101,-630),Vector3(-8,2,-734))
	await fixture(Vector3(-25,2.54,-646),[
		[Vector3(-9,2.24,-646),"Cheng Dao to pavement"],[Vector3(9,2.24,-646),"main road lowered crossing"],
		[Vector3(27,2.24,-646),"Le Tian brick court"],[Vector3(27,2.24,-652),"Le Tian entry alignment"],
		[Vector3(46,2.24,-652),"Le Tian door from road"]])
	await fixture(Vector3(-9,2.54,-735),[
		[Vector3(-55,2.24,-735),"Main Square central approach"],[Vector3(-100,2.24,-735),"Zhi Xin court connection"],
		[Vector3(-55,2.24,-735),"Main Square return"],[Vector3(9,2.24,-735),"Main Square road crossing"],
		[Vector3(45,2.24,-735),"Zhiren paved forecourt"]])
	await fixture(Vector3(-9,2.54,-805),[
		[Vector3(-45,2.24,-805),"Dao Yuan portal approach"],[Vector3(-9,2.24,-805),"Dao Yuan return"],
		[Vector3(-9,2.24,-839),"south junction pavement"],[Vector3(-120,2.24,-839),"corrected crossroad bypasses building"],
		[Vector3(-120,2.24,-855),"old gate sidewalk connection"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":3,"build_ms":world.built_ms,"no_teleport_within_each_fixture":true,"scope":"continuous street, five entry connections and road bypass; retained building anchors"}
	FileAccess.open("res://tests/artifacts/start_zone_street_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("START_STREET ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
