extends "res://tests/LibraryPlanCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("roof",Vector3(-5,66,-357),Vector3(84,14,-290))
	await capture("plan",Vector3(79,122,-285),Vector3(78,0,-290))
	await capture("rear-wings",Vector3(159,44,-320),Vector3(91,17,-286))
	await capture("front",Vector3(2,12,-237),Vector3(78,14,-290))
	await capture("pond",Vector3(116,5.2,-361),Vector3(81,13,-320))
	await capture("terrace",Vector3(106,13,-306),Vector3(88,14,-292))
	await capture("study",Vector3(77,12.7,-293),Vector3(85,12.1,-318))
	await capture("stair",Vector3(96,8.3,-282),Vector3(81,11.6,-282))
	await fixture(Vector3(95.6,6.94,-282),[
		[Vector3(79.8,11.04,-282),"3F stair ascent"],[Vector3(76,11.04,-282),"3F landing"],
		[Vector3(76,11.04,-300),"3F transverse reading aisle"],[Vector3(83,11.04,-300),"3F rear study approach"],
		[Vector3(91,11.04,-300),"3F terrace doorway"],[Vector3(97,11.04,-303),"3F outdoor study terrace"],
		[Vector3(91,11.04,-300),"terrace return"],[Vector3(83,11.04,-300),"study return"],
		[Vector3(76,11.04,-300),"landing aisle return"],[Vector3(76,11.04,-282),"3F stair head"],
		[Vector3(95.6,6.64,-282),"3F stair descent"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"corrected stair opening and new 3F terrace/study route only; eight passed retained-access legs reused from initial milestone"}
	FileAccess.open("res://tests/artifacts/library_plan_final.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_PLAN_FINAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
