extends "res://tests/ZhangDatumV137.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true;building=world.builder.buildings.teaching_c
	probe("photo entry stays open",pos(18,37,1.3),pos(18,32,1.3),false)
	probe("photo plain surround stays solid",pos(14.9,37,1.3),pos(14.9,34,1.3),true)
	await capture("teaching-cd-v138-entry",pos(22,49,3.1),pos(15,29,2))
	FileAccess.open("res://tests/artifacts/teaching_cd_v138_entry_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"checks":checks,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
