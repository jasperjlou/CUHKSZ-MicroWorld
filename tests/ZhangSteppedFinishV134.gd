extends "res://tests/ZhangSteppedPlanV134.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true;building=world.builder.buildings.zhang_lingbin
	await capture("zhang-plan-v134-overview",pos(0,70,135),pos(0,0))
	await capture("zhang-plan-v134-interior",pos(-24.4,8,6.6),pos(-24.4,-18,6.5))
	await capture("zhang-plan-v134-bridge",pos(-21.5,29,10.3),pos(-21.5,13,10.3))
	await capture("zhang-plan-v134-notch",pos(-5,25,16),pos(-19,-4,9))
	FileAccess.open("res://tests/artifacts/zhang_plan_v134_finish_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
