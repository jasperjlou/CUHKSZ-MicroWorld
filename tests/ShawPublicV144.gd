extends "res://tests/ShawWestPlanV143.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	building=world.builder.buildings.shaw_west.get_node("WestPlanFrameV143")
	if DisplayServer.get_name()!="headless":
		await capture("shaw-public-v144-window-layers",wp(-14,7,23),wp(-18,8,7))
		await capture("shaw-public-v144-hall",wp(2.8,10.4,-10),wp(-3,10.4,-24))
		await capture("shaw-public-v144-mid-room",wp(-18,10.4,0),wp(-10,10.4,8))
		await capture("shaw-public-v144-stair",wp(-7,9,33),wp(7,6,21))
		await capture("shaw-public-v144-roof-side",Vector3(177,19,-679),Vector3(154,14.34,-665))
		world.ui.show();world.minimap.show()
		await capture("shaw-public-v144-map",wp(45,75,52),wp(-10,10,-2))
		FileAccess.open("res://tests/artifacts/shaw_public_v144_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"));quit();return
	for y:float in [4.4,8.8]:
		await fixture(wp(-18,y+.3,-5),[[wp(-18,y,0),"middle room door"],[wp(-28,y,0),"middle room left"],[wp(-28,y,6),"middle front windows"],[wp(-9,y,6),"middle room right"],[wp(-9,y,0),"middle return"],[wp(-18,y,0),"middle aisle"],[wp(-18,y,-5),"middle exit"]])
		probe("middle front glass "+str(y),wp(-18,y+1.5,7),wp(-18,y+1.5,9),true)
		probe("middle rear door "+str(y),wp(-18,y+1.5,-4),wp(-18,y+1.5,-1),false)
	probe("hall glazing collision",wp(-4,10,-20),wp(-6,10,-20),true)
	probe("hall existing opening",wp(2.8,10,-5),wp(2.8,10,-9),false)
	FileAccess.open("res://tests/artifacts/shaw_public_v144_physics.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":2,"failures":failures},"\t"));quit(0 if failures.is_empty() else 1)
