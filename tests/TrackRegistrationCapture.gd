extends "res://tests/CourtyardRefinementCapture.gd"
const A := preload("res://world/visual_campus/AthleticsGround.gd")
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("track-overview-v59",Vector3(-145,125,-1125),Vector3(-12,0,-1030))
	await capture("track-complex-interface-v59",Vector3(77,12,-989),Vector3(-8,3,-977))
	await capture("track-finish-v59",Vector3(44,8,-1091),Vector3(24,2,-1072))
	var shape: Dictionary=world.builder.buildings["track"].get_meta("track_geometry")
	var poly:=A.oval(36.8);var length:=0.0
	for i in poly.size():length+=poly[i].distance_to(poly[(i+1)%poly.size()])
	shape["actual_polygon_length"]=length
	if absf(length-400.001)>.01 or shape.lanes!=9 or absf(shape.lane_width-1.22)>.001:failures.append("standard track geometry")
	# A physical circuit inside the running surface, not a timed lane1 distance certification.
	var route: Array=[[Vector3(0,2.24,-979),"Complex-side boundary opening"],[Vector3(0,2.24,-988),"entry onto track"]]
	for side in [1,-1]:
		for j in 7:
			var angle: float=PI/2-j*PI/6+(PI if side<0 else 0)
			var target:=Vector3(-14+side*42.195+cos(angle)*42,2.24,-1030+sin(angle)*42)
			route.append([target,"oval segment %s %s" % [side,j]])
	route.append([Vector3(0,2.24,-988),"track circuit closes"])
	route.append([Vector3(0,2.24,-973),"return through Complex-side opening"])
	await fixture(Vector3(0,2.54,-973),route)
	await fixture(Vector3(91,2.54,-1030),[
		[Vector3(77,2.24,-1030),"positive end boundary opening"],[Vector3(70,2.24,-1030),"end opening to running track"],
		[Vector3(77,2.24,-1030),"end track return"],[Vector3(91,2.24,-1030),"positive end opening exit"]])
	await fixture(Vector3(-117,2.54,-1030),[
		[Vector3(-105,2.24,-1030),"opposite end boundary opening"],[Vector3(-98,2.24,-1030),"opposite end to running track"],
		[Vector3(-105,2.24,-1030),"opposite end return"],[Vector3(-117,2.24,-1030),"opposite end exit"]])
	await fixture(Vector3(0,2.54,-1094),[
		[Vector3(0,2.24,-1081),"far boundary opening"],[Vector3(0,2.24,-1072),"far opening to running track"],
		[Vector3(0,2.24,-1081),"far opening return"],[Vector3(0,2.24,-1094),"far path return"]])
	var report: Dictionary={"version":world.data.version,"geometry":shape,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"V59 standard-dimension model and affected field boundary circulation only; campus coordinates, grades and fence gate positions remain fitted, not measured or certified."}
	FileAccess.open("res://tests/artifacts/track_registration_v59.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TRACK_REGISTRATION ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
