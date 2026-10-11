extends "res://tests/GardenBackStreetCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("garden-rear-street-v80",Vector3(127,7,-778),Vector3(66,5,-776))
	await capture("garden-road-interface-v80",Vector3(114,21,-787),Vector3(82,4,-760))
	await capture("tower-road-bend-v80",Vector3(43,7,-806),Vector3(50,5,-771))
	await capture("garden-street-layout-v80",Vector3(137,65,-814),Vector3(80,3,-768))
	await fixture(Vector3(45,2.65,-784),[
		[ground(45,-782),"turn approach"],[ground(47.65,-777.54),"follow road curved centre"],
		[ground(55,-778),"leave bend on road centre"],[ground(78,-778),"road beside garden"],
		[ground(105,-781),"road eastern stretch"],[ground(130,-781),"service junction"],
		[ground(143,-760),"service north connection"],[ground(130,-781),"service junction return"],
		[ground(130,-810),"service south descent"]])
	await fixture(ground(78,-784)+Vector3.UP*.3,[[ground(78,-778),"cross flush road edge from planted verge"],[ground(78,-772.6),"cross road to garden sidewalk"],[ground(78,-778),"sidewalk return to road"],[ground(78,-784),"road return to planted verge"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"V80 road curve,service branches and softened asphalt edge;4 east approach and12 west/tower legs retained from prior reports;grade still fitted"}
	FileAccess.open("res://tests/artifacts/garden_back_street_road_finish_v80.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("GARDEN_BACK_STREET_ROAD_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
