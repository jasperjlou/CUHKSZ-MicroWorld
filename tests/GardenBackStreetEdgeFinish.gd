extends "res://tests/GardenBackStreetCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("garden-rear-street-v80",Vector3(127,7,-778),Vector3(66,5,-776))
	await capture("garden-road-interface-v80",Vector3(114,21,-787),Vector3(82,4,-760))
	await capture("tower-road-bend-v80",Vector3(43,7,-806),Vector3(50,5,-771))
	await capture("garden-street-layout-v80",Vector3(137,65,-814),Vector3(80,3,-768))
	await fixture(ground(78,-784)+Vector3.UP*.3,[[ground(78,-778),"cross road edge from verge"],[ground(78,-772.6),"road to sidewalk softened edge"],[ground(78,-778),"sidewalk back to road"],[ground(78,-784),"road back to verge"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"V80 only softened sidewalk edge;retains east4,west12,road9 previous legs;all metric values fitted"}
	FileAccess.open("res://tests/artifacts/garden_back_street_edge_finish_v80.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("GARDEN_BACK_STREET_EDGE_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
