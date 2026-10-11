extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("start-registration-v82",Vector3(-202,112,-800),Vector3(-65,5,-735))
	await capture("daoyuan-perimeter-v82",Vector3(-176,7,-749),Vector3(-122,14,-733))
	await capture("zhixin-clock-junction-v82",Vector3(-17,7,-807),Vector3(-95,5,-783))
	await capture("lower-courts-v82",Vector3(-146,26,-678),Vector3(-111,3,-647))
	await capture("court-ground-v82",Vector3(-121,4,-661),Vector3(-105,4,-635))
	var report:Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"scope":"V82 corrected DaoYuan and OldGate registration,two outdoor courts and affected links;metric scale and full-campus fidelity remain partial"}
	FileAccess.open("res://tests/artifacts/start_zone_registration_visual_v82.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("START_REGISTRATION_VISUAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
