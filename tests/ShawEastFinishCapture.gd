extends "res://tests/ShawEastDetailCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("whole",Vector3(12,18,-495),Vector3(80,18,-540))
	await capture("louver",Vector3(41,16,-512),Vector3(60,20,-516))
	await capture("roofwalk",Vector3(61,8.9,-540),Vector3(68,8,-556))
	var report: Dictionary={"captures":captures,"failures":failures,"build_ms":world.built_ms,"scope":"End-wall detail now faces outward on both ends; roof surface finish only. No changed collision."}
	FileAccess.open("res://tests/artifacts/shaw_east_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_EAST_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
