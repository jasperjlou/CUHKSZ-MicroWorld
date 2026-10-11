extends "res://tests/ZhangDatumV137.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true;building=world.builder.buildings.zhang_lingbin
	await capture("zhang-datum-v137-lower",pos(1,-41,-2.9),pos(-18,-21,-2.5))
	await capture("zhang-datum-v137-side",pos(-38.5,-34,-2.6),pos(-38.5,-8,1))
	await capture("zhang-datum-v137-bridge",pos(-21.5,30,6.6),pos(-21.5,13,5.3))
	probe("roof bridge side gap guarded",pos(-24.1,15,8.025),pos(-24.1,17,8.025),true)
	probe("roof bridge centre remains open",pos(-21.5,15,8.025),pos(-21.5,17,8.025),false)
	FileAccess.open("res://tests/artifacts/zhang_datum_v137_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"checks":checks,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
