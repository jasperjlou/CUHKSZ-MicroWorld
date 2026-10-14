extends "res://tests/LibraryLowerLevelCapture.gd"
const B=preload("res://world/visual_campus/VisualCampusBuilder.gd")
const Bank244=preload("res://world/visual_campus/RearRoadBank.gd")
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(20)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var route:Array=[]
	for r:Dictionary in world.data.routes:
		if r.id=="library_rear_shaw_avenue":route=r.points
	var garden:Node3D=world.find_child("ShawRoadGardenV244",true,false)
	var inventory:Dictionary=garden.get_meta("inventory")
	var minimum:float=1000
	for p:Array in inventory.near_plant_centres:minimum=minf(minimum,p[0]-Bank244.road_x(p[1],route)-3)
	var checks:Array=[{"case":"near planting centres outside rear road edge","minimum_x_clearance":minimum,"valid":minimum>4.0}]
	if minimum<=4.0:failures.append("plant centre road clearance")
	await capture("shaw-junction-v244-final",Vector3(125,11,-497),Vector3(114,6,-502))
	FileAccess.open("res://tests/artifacts/shaw_junction_final_v244.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"checks":checks,"inventory":inventory,"failures":failures,"scope":"Fitted garden and border visuals only;collision vertices unchanged;plant-centre separation is not foliage clearance or walk/camera testing;no new physical legs"},"\t"))
	print("SHAW_JUNCTION_FINAL_V244 ",JSON.stringify({"checks":checks,"trees":inventory.trees,"shrubs":inventory.shrubs,"failures":failures}));quit(0 if failures.is_empty() else 1)
