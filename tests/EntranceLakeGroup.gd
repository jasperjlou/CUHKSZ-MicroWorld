extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("entrance-lake-aerial-v68",Vector3(177,54,51),Vector3(76,12,-20))
	await capture("entrance-hall-street-v68",Vector3(100,8,65),Vector3(67,16,-5))
	await capture("entrance-spiral-v68",Vector3(115,12,-11),Vector3(103,5,-24))
	await capture("entrance-curved-link-v68",Vector3(115,16,-27),Vector3(89,15,-23))
	var route:Array=[
		[Vector3(86,0,12),"foyer outside stair rail"],[Vector3(90,0,12),"foyer stair toe"],[Vector3(90,4.4,-10),"foyer stair ascent"],
		[Vector3(93,4.4,-10),"foyer stair landing"],[Vector3(93,4.4,-1),"upper foyer window aisle"],
		[Vector3(97,4.4,-1),"open glazed upper foyer door"],[Vector3(97,4.4,-17),"gallery to spiral court"],
		[Vector3(111,4.4,-17),"court crosses below curved bridge"],[Vector3(111,4.4,-24),"spiral radial landing"],
		[Vector3(107,4.4,-24),"spiral first landing"]]
	# Small angular legs follow the actual annular flight, with no repositioning.
	for i in range(1,25):
		var a:float=i*TAU/24
		route.append([Vector3(104+cos(a)*3,4.4+4.4*i/24,-24+sin(a)*3),"spiral upper flight %02d"%i])
	route.append_array([[Vector3(111,8.8,-24),"upper spiral radial exit"],[Vector3(111,8.8,-17),"upper court front aisle"],[Vector3(97,8.8,-17),"upper court hall return"],[Vector3(97,8.8,-31),"rear deck approach"],[Vector3(85,8.8,-31),"rear stair toe"],[Vector3(85,13.2,-13),"upper bridge access stair"],[Vector3(90,13.2,-13),"curved link south entrance"]])
	for i in range(1,11):
		var t:float=float(i)/10
		route.append([Vector3(90+sin(t*PI)*3.8,13.2,-15-t*19),"curved glazed link %02d"%i])
	route.append_array([[Vector3(91,13.2,-36),"bridge north landing"],[Vector3(109,13.2,-36),"lake tower upper gallery connection"]])
	await fixture(Vector3(70,.3,8),route)
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"fixtures":1,"no_teleport_within_fixture":true,"scope":"ground foyer to upper foyer,spiral upper flight and curved bridge into lake tower;lower spiral and return next only if affected;no full auditorium/core claim"}
	FileAccess.open("res://tests/artifacts/entrance_lake_group_finish_v68.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ENTRANCE_LAKE_GROUP ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
