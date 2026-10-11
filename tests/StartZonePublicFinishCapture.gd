extends "res://tests/StartZonePublicCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("le-tian",Vector3(8,8,-620),Vector3(46,10,-652))
	await capture("le-tian-entry",Vector3(33,4.2,-643),Vector3(48,4,-658))
	await capture("zhi-ren",Vector3(15,12,-759),Vector3(57,10,-734))
	await capture("zhi-xin",Vector3(-52,9,-694),Vector3(-115,9,-733))
	await capture("library-corner",Vector3(-87,4.3,-715),Vector3(-105,5.9,-697))
	await capture("paving-context",Vector3(-25,38,-308),Vector3(40,5,-359))
	var report: Dictionary={"captures":captures,"failures":failures,"build_ms":world.built_ms,"scope":"source-supported blank library end wall and end glazing; distant mortar anti-aliasing. Previously passed circulation avoids the closed end face; no repeated route test."}
	FileAccess.open("res://tests/artifacts/start_zone_public_visual_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("START_PUBLIC_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
