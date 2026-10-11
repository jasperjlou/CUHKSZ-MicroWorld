extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await fixture(Vector3(62,7.465,-554.28),[
		[Vector3(62,7.165,-526.5),"public roof traverse before residential wing"],[Vector3(62,7.165,-554.28),"public roof return"],
		[Vector3(70,7.165,-554.28),"stair landing return"],[Vector3(87,2.24,-554.28),"stair descent"],
		[Vector3(80,2.24,-540),"court return"],[Vector3(48,2.24,-540),"main exit"]])
	var report: Dictionary={"failures":failures,"physical_legs":legs,"fixtures":1,"build_ms":world.built_ms,"scope":"Remaining six legs only. Roof destination kept in public bridge before the north residential wall; twelve earlier passes retained."}
	FileAccess.open("res://tests/artifacts/shaw_east_roof_access.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_EAST_ROOF ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
