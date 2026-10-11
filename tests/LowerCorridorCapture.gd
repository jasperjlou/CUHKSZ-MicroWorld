extends "res://tests/CourtyardRefinementCapture.gd"

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("corridor-garden",Vector3(30,4,-426),Vector3(39,4,-494))
	await capture("corridor-shaw",Vector3(34,5,-495),Vector3(66,7,-559))
	await capture("corridor-between",Vector3(110,6,-585),Vector3(116,7,-662))
	await capture("corridor-research",Vector3(112,5,-753),Vector3(82,8,-855))
	await capture("corridor-sports",Vector3(62,4,-843),Vector3(0,6,-853))
	await capture("corridor-overall",Vector3(-104,150,-453),Vector3(63,0,-688))
	await capture("corridor-square-cluster",Vector3(-34,42,-662),Vector3(85,8,-704))
	await capture("corridor-research-canopy",Vector3(39,5,-813),Vector3(88,8,-848))
	await fixture(Vector3(40,2.54,-320),[
		[Vector3(40,2.24,-332),"library front paving"],[Vector3(9,2.24,-332),"sunken court west bypass"],
		[Vector3(9,2.24,-386),"student front approach"],
		[Vector3(30,2.24,-400),"corridor start"],[Vector3(30,2.24,-428),"bridge approach"],
		[Vector3(30,2.24,-476),"under bridge without stair collision"],[Vector3(42,2.24,-502),"Shaw paved avenue"],
		[Vector3(42,2.24,-535),"Shaw east entry"],[Vector3(42,2.24,-571),"Shaw corner"],
		[Vector3(24,2.24,-601),"Shaw to square turn"],[Vector3(9,2.24,-632),"square avenue"],
		[Vector3(9,2.24,-666),"Cheng Dao approach"],[Vector3(45,2.24,-666),"relocated Cheng Dao threshold"],
		[Vector3(9,2.24,-666),"Cheng Dao return"],[Vector3(9,2.24,-697),"cluster cross path"],
		[Vector3(82,2.24,-697),"lane between old academic wings"],[Vector3(82,2.24,-713),"Le Tian approach"],
		[Vector3(105,2.24,-713),"relocated Le Tian threshold"],[Vector3(82,2.24,-713),"Le Tian return"],
		[Vector3(82,2.24,-697),"cluster lane return"],[Vector3(9,2.24,-697),"square return"],
		[Vector3(9,2.24,-750),"Zhiren front"],[Vector3(9,2.24,-805),"research turn"],
		[Vector3(28,2.24,-811),"research approach"],[Vector3(43,2.24,-837),"research tree walk"],
		[Vector3(54,2.24,-845),"research corner"],[Vector3(68,2.24,-849),"research canopy"],
		[Vector3(55,2.24,-853),"sports connection"],
		[Vector3(0,2.24,-853),"sports hall front"]])
	var report:={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"continuous_route":true,"build_ms":world.built_ms}
	FileAccess.open("res://tests/artifacts/lower_corridor_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LOWER_CORRIDOR ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
