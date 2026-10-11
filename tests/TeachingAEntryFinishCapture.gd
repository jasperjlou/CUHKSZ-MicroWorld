extends "res://tests/TeachingAEntryCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("long-hall",Vector3(-47,4.1,-99),Vector3(-50,6.3,-128))
	await capture("glazed-entry",Vector3(-43,4.2,-115),Vector3(-56,6.0,-115))
	await capture("outer-screen",Vector3(-49,4.2,-122),Vector3(-32,7,-125))
	await capture("court",Vector3(-69,5,-115),Vector3(-53,12,-103))
	await capture("front",Vector3(-17,15,-80),Vector3(-61,13,-113))
	var report: Dictionary={"captures":captures,"failures":failures,"build_ms":world.built_ms,"scope":"Visual finish: clerestory divided by wall piers; inner column moved out of doorway, increasing clearance. Reuses 16 passed traversal legs."}
	FileAccess.open("res://tests/artifacts/teaching_a_entry_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TEACHING_A_ENTRY_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
