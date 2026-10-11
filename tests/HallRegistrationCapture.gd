extends "res://tests/CourtyardRefinementCapture.gd"
const O:=Vector3(-10,2.24,-880)
func wp(x: float,y: float,z: float) -> Vector3:return O+Vector3(z,y,-x)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("hall-perpendicular-overview-v62",Vector3(-100,95,-990),Vector3(-10,8,-910))
	await capture("hall-registered-portal-v62",Vector3(63,8,-881),Vector3(5,11,-893))
	await capture("hall-registered-side-v62",Vector3(-4,6,-927),Vector3(-16,9,-906))
	await capture("hall-registered-rear-v62",Vector3(-65,8,-868),Vector3(-35,10,-875))
	await fixture(Vector3(51,2.54,-845),[
		[Vector3(44,2.24,-845),"Research approach connection"],[Vector3(44,2.24,-890),"new Hall forecourt"],
		[wp(10,0,40),"portal stair foot"],[wp(10,.84,32),"registered front stair"],
		[wp(10,.84,21),"registered portal"],[wp(10,.84,12),"registered reception"],
		[wp(10,.84,32),"reception return"],[wp(10,0,40),"stair descent"],
		[Vector3(44,2.24,-890),"forecourt return"],[Vector3(44,2.24,-928),"Hall to Complex corner"],
		[Vector3(-10,2.24,-928),"perpendicular halls gap"],[Vector3(-47,2.24,-928),"Hall back corner"],
		[Vector3(-47,2.24,-833),"rear glazing promenade"],[Vector3(-10,2.24,-833),"Hall opposite side"],
		[Vector3(30,2.24,-833),"side to front corner"],[Vector3(44,2.24,-833),"outer forecourt corner"],
		[Vector3(44,2.24,-928),"full front-side bypass"],[Vector3(-10,2.24,-928),"between-hall return"],
		[Vector3(-10,2.24,-947),"Complex open ground passage"],[Vector3(-10,2.24,-965),"Complex field exit"],
		[Vector3(-10,2.24,-970),"field edge connection"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"V62 final90degree Hall turn and10m shift; all old Hall absolute-route records superseded. Actual lengths and global north fitted; continuous Research-front-rear-Complex-field ground route."}
	FileAccess.open("res://tests/artifacts/hall_registration_v62.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("HALL_REGISTRATION ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
