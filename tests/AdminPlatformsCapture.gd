extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("admin-forecourt-v40",Vector3(17,9,-158),Vector3(50,3,-183))
	await capture("admin-lookout-v40",Vector3(105,17,-176),Vector3(114,16,-165))
	await capture("admin-rear-step-v40",Vector3(101,16.4,-168),Vector3(114,15.5,-167))
	await capture("tb-mall-seam-v40",Vector3(-30,5,-188),Vector3(-43,3,-245))
	await fixture(Vector3(20,2.54,-180),[
		[Vector3(40,2.24,-180),"clear stone axis across removed lawn"],
		[Vector3(56,2.24,-180),"forecourt to broad stair foot"],
		[Vector3(75,6.64,-180),"main first stair retained"],
		[Vector3(56,2.24,-180),"main stair descent"],
		[Vector3(40,2.24,-180),"forecourt return"],
		[Vector3(40,2.24,-198),"stone south edge of cleared apron"],
		[Vector3(20,2.24,-198),"cleared apron to central mall"]])
	await fixture(Vector3(96,14.94,-168),[
		[Vector3(107,14.64,-168),"rear low terrace to lookout stair"],
		[Vector3(113,15.24,-168),"four low steps onto raised overlook"],
		[Vector3(115,15.24,-168),"overlook inner aisle"],
		[Vector3(112,15.24,-168),"overlook return to stair head"],
		[Vector3(107,14.64,-168),"lookout stair descent"],
		[Vector3(96,14.64,-168),"rear low terrace return"]])
	await fixture(Vector3(-39,2.54,-185),[
		[Vector3(-39,2.24,-220),"TB gate-side mall threshold"],
		[Vector3(-48,2.24,-220),"TB arcade interface"],
		[Vector3(-39,2.24,-220),"TB arcade to mall return"],
		[Vector3(-39,2.24,-253),"TB threshold to library-side crossing"],
		[Vector3(-30,2.24,-253),"TB cross-zone stone exit"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":3,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"Administrative front paving, fitted small rear overlook and TB mall seam. Not rear storey registration or whole B-zone acceptance."}
	FileAccess.open("res://tests/artifacts/admin_platforms_v40.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ADMIN_PLATFORMS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
