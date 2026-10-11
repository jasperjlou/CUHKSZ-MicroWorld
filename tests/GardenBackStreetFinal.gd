extends "res://tests/CourtyardRefinementCapture.gd"
func ground(x:float,z:float) -> Vector3:
	return Vector3(x,world.builder.height(x,z)+.14,z)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("garden-rear-street-v80",Vector3(127,7,-778),Vector3(66,5,-776))
	await capture("garden-road-interface-v80",Vector3(114,21,-787),Vector3(82,4,-760))
	await capture("tower-road-bend-v80",Vector3(43,7,-806),Vector3(50,5,-771))
	await capture("garden-street-layout-v80",Vector3(137,65,-814),Vector3(80,3,-768))
	var checks:Array=[]
	for x in [60.0,80.0,100.0,120.0]:
		# Road edges follow one longitudinal profile, without inherited terrace cross slope.
		var nearest:Dictionary={"distance":1000.0,"z":0.0}
		for p:Array in world.builder.garden_rear_route:
			if absf(p[0]-x)<nearest.distance:nearest={"distance":absf(p[0]-x),"z":p[2]}
		var a:float=world.builder.height(x,nearest.z-3);var b:float=world.builder.height(x,nearest.z+3)
		var valid:bool=absf(a-b)<.10 and a>=2.24 and a<=4.65
		checks.append({"x":x,"lane_edge_y":[a,b],"valid":valid})
		if not valid:failures.append("road crossfall "+str(x))
	await fixture(Vector3(78,4.94,-772.6),[
		[ground(54,-773),"western approach junction"],[ground(59,-770),"western approach ascent"],
		[ground(62,-765),"garden lawn edge landing"],[ground(62,-751),"retained garden front walk"],
		[ground(62,-765),"return to garden approach"],[ground(59,-770),"western approach descent"],
		[ground(54,-773),"return to road-side path"],[ground(43,-775),"rounded street corner"],
		[ground(39,-785),"tower-side sidewalk connection"],[ground(39,-817),"tower-side sidewalk continuation"],
		[ground(45,-817),"sidewalk to existing service road"],[ground(45,-784),"flat road near tower garden"],
		[ground(55,-778),"road curve"],[ground(78,-778),"road beside garden"],
		[ground(105,-781),"road eastern stretch"],[ground(130,-781),"hillside service road junction"],[ground(143,-760),"service north connection"],[ground(130,-781),"service junction return"],[ground(130,-810),"service south descent"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"scope":"V80 local rear-road crossfall,garden links and tower-side sidewalk;absolute grade,width and alignment remain fitted"}
	FileAccess.open("res://tests/artifacts/garden_back_street_final_v80.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("GARDEN_BACK_STREET ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
