extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("ground-final-v183-gate",Vector3(-4,20,-57),Vector3(0,2.3,-119))
	await capture("ground-final-v183-admin",Vector3(-38,14,-219),Vector3(28,2.4,-181))
	await capture("ground-final-v183-student-link",Vector3(-27,9,-437),Vector3(38,3,-396))
	await capture("ground-final-v183-shaw",Vector3(10,25,-588),Vector3(125,4,-603))
	await capture("ground-final-v183-old-library",Vector3(-5,24,-632),Vector3(-46,3,-697))
	await capture("ground-final-v183-tower",Vector3(-12,12,-772),Vector3(112,9,-916))
	await capture("ground-final-v183-sports",Vector3(-87,17,-999),Vector3(30,3,-946))
	await capture("ground-final-v183-perimeter",Vector3(-164,9,-1126),Vector3(-105,2,-1065))
	FileAccess.open("res://tests/artifacts/ground_release_final_v183.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"scope":"Visual-only ground finishes,Shaw planting and distant woodland;physical topology unchanged"},"\t"))
	print("GROUND_RELEASE_REVIEW_DONE");quit(0 if failures.is_empty() else 1)
