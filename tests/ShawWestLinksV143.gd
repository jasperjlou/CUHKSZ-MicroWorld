extends "res://tests/ShawWestPlanV143.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	building=world.builder.buildings.shaw_west.get_node("WestPlanFrameV143")
	await fixture(wp(-18,9.1,-5),[
		[wp(5,8.8,-5),"public corridor"],[wp(8,8.8,-3),"roof stair approach"],[wp(8,12.1,-13),"roof stair head"],
		[wp(0,12.1,-13),"roof cross aisle"],[wp(0,12.1,-25),"roof garden"],[wp(8,12.1,-25),"roof bridge approach"],
		[Vector3(191,14.34,-665),"hill bridge"],[Vector3(205,world.builder.height(205,-665)+.055,-665),"hill endpoint"],
		[Vector3(191,14.34,-665),"hill return"],[wp(8,12.1,-25),"roof return"],[wp(0,12.1,-25),"garden return"],
		[wp(0,12.1,-13),"roof aisle return"],[wp(8,12.1,-13),"roof stair return"],[wp(8,8.8,-3),"roof stair descent"],
		[wp(5,8.8,-5),"public corridor return"],[wp(-18,8.8,-5),"central corridor return"]])
	await fixture(Vector3(110,2.54,-605),[
		[Vector3(136,2.24,-604),"new entry approach"],[wp(9,0,36),"forecourt approach"],[wp(9,.05,32),"covered forecourt"],[wp(9,.05,28.7),"new ground foyer"],
		[wp(9,.05,32),"foyer exit"],[wp(9,0,36),"forecourt return"],[Vector3(136,2.24,-604),"approach return"],
		[Vector3(110,2.24,-605),"back to street"],[Vector3(110,world.builder.height(110,-680),-680),"street to perimeter return"],
		[Vector3(178.5,2.24,-680),"rear walkway return"],[Vector3(178.5,2.24,-665),"below hill bridge"],[Vector3(178.5,2.24,-605),"rear walkway retained"]])
	probe("low path under hill bridge",Vector3(178.5,3.24,-665),Vector3(178.5,8.24,-665),false)
	level_probe("ground foyer not terrain",7,28.7,.05)
	FileAccess.open("res://tests/artifacts/shaw_west_v143_links.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":2,"failures":failures,"scope":"new-plan perimeter and corrected fitted 4F side bridge, two separate starts; no measured site alignment claim"},"\t"))
	quit(0 if failures.is_empty() else 1)

