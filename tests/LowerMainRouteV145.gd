extends "res://tests/ZhangDatumV137.gd"
var itinerary:Array[Vector3]=[]
func add_points(points:Array)->void:
	for p:Vector3 in points:
		if not itinerary.is_empty():
			var start:Vector3=itinerary.back();var pieces:=ceili(start.distance_to(p)/30)
			for i in range(1,pieces):itinerary.append(start.lerp(p,float(i)/pieces))
		itinerary.append(p)
func route(id:String,reverse:bool=false)->void:
	for r:Dictionary in world.data.routes:
		if r.id!=id:continue
		var points:Array=[]
		for p:Array in r.points:points.append(world.builder.point(p))
		if reverse:points.reverse()
		add_points(points);return
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false)
	# One continuous body from gate to lower-campus anchors, no chapter/fixture cuts.
	add_points([Vector3(-18,0,-39.5),Vector3(-17.3,0,-39.5),Vector3(-17.3,1.12,-46),Vector3(-17.3,2.24,-55.5),Vector3(-35,2.24,-57),Vector3(-35,2.24,-98),Vector3(-35,2.24,-320),Vector3(-35,2.24,-334),Vector3(14,2.24,-334),Vector3(34,2.24,-334),Vector3(54,2.24,-334),Vector3(60,2.24,-334),Vector3(60,2.24,-330),Vector3(60,2.24,-325),Vector3(60,2.24,-302),Vector3(60,2.24,-325),Vector3(60,2.24,-334),Vector3(14,2.24,-334),Vector3(8,2.24,-334),Vector3(8,2.24,-400),Vector3(30,2.24,-400)])
	route("student_south_garden")
	add_points([Vector3(-9,2.24,-668),Vector3(-20.5,2.24,-674.8),Vector3(-20.5,2.24,-689),Vector3(-8.1,2.24,-689),Vector3(-8.1,2.24,-700),Vector3(-8.1,2.24,-733),Vector3(-20,2.24,-733),Vector3(-44,2.24,-733),Vector3(-51,2.24,-733),Vector3(-44,2.24,-733),Vector3(-8.1,2.24,-733),Vector3(-8.1,2.24,-833),Vector3(9.4,2.24,-833),Vector3(9.4,2.24,-829)])
	route("research_canopy_access");route("research_public_terrace");route("research_public_terrace",true);route("research_canopy_access",true)
	route("tower_hall_covered_walk")
	var movement:Array=[]
	for i in itinerary.size():movement.append([itinerary[i],"main itinerary "+str(i)])
	await fixture(itinerary[0]+Vector3.UP*.3,movement)
	FileAccess.open("res://tests/artifacts/lower_main_route_v145.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"planned_legs":itinerary.size(),"fixtures":1,"failures":failures,"scope":"Gate,teaching frontage,library side,student lower corridor,Shawfront curved walk,Zhixin,research terrace andsportsfront;onebodycontinuous;not allrooms/rearbranches."},"\t"))
	quit(0 if failures.is_empty() else 1)
