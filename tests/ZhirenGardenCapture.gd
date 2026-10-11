extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("zhiren-deck-v79",Vector3(102,6.35,-752),Vector3(51,7,-756))
	await capture("zhiren-seating-v79",Vector3(88,6.25,-753.5),Vector3(83,6.1,-763))
	await capture("zhiren-garden-layout-v79",Vector3(73,42,-791),Vector3(83,5,-739))
	await capture("letian-rear-path-v79",Vector3(128,6.3,-747),Vector3(128,5.4,-697))
	await fixture(Vector3(81,4.94,-734),[
		[Vector3(81,4.64,-751),"Zhiren column gap to timber walk"],
		[Vector3(62,4.64,-751),"front of rock lawn"],[Vector3(62,4.64,-743),"second colonnade opening"],
		[Vector3(62,4.64,-751),"second opening return"],[Vector3(72,4.64,-751),"deck junction"],
		[Vector3(72,4.64,-760),"seating side aisle"],[Vector3(72,4.64,-755.5),"return around tables"],
		[Vector3(100,4.64,-755.5),"seating front aisle"],[Vector3(100,4.64,-751),"deck exit"],
		[Vector3(128,4.64,-751),"LeTian rear corner"],[Vector3(128,4.64,-680),"rear perimeter full length"],
		[Vector3(97,4.64,-680),"around LeTian end"],[Vector3(97,4.64,-713),"LeTian front approach"],
		[Vector3(110,4.64,-713),"LeTian existing public entrance"],[Vector3(97,4.64,-713),"entrance return"],
		[Vector3(97,4.64,-680),"front side return"],[Vector3(128,4.64,-680),"end corner return"],
		[Vector3(128,4.64,-751),"rear path return"],[Vector3(81,4.64,-751),"timber frontage return"],
		[Vector3(81,4.64,-734),"Zhiren colonnade reentry"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"V79 garden and LeTian perimeter;panorama date unknown,dimensions and site registration fitted;no full-campus acceptance"}
	FileAccess.open("res://tests/artifacts/zhiren_garden_v79.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ZHIRREN_GARDEN ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
