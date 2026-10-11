extends "res://tests/ShawWestPlanV143.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	building=world.builder.buildings.shaw_west.get_node("WestPlanFrameV143")
	await capture("shaw-west-v143-courts-final",wp(-5,100,10),wp(-9,0,-5))
	await capture("shaw-west-v143-bridge-final",Vector3(177,19,-679),Vector3(154,14.34,-665))
	FileAccess.open("res://tests/artifacts/shaw_west_v143_finish_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
