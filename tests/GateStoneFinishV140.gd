extends "res://tests/GateABRoadV140.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-ab-v140-step",Vector3(-12,3.5,-36),Vector3(-17.3,1.5,-48))
	await capture("gate-ab-v140-apron",Vector3(-20.5,2.8,-37.5),Vector3(-15,1.3,-44))
	FileAccess.open("res://tests/artifacts/gate_stone_v140_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"scope":"only noncolliding decorative apron edges clipped; existing physics retained","failures":failures},"\t"))
	quit(0)
