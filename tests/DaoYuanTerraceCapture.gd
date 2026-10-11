extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("daoyuan-front-v55",Vector3(-3,7,-797),Vector3(-56,14,-805))
	await capture("daoyuan-court-v55",Vector3(-35,9,-782),Vector3(-58,11,-805))
	await capture("daoyuan-overview-v55",Vector3(20,70,-853),Vector3(-50,7,-803))
	await fixture(Vector3(-9,2.54,-770),[
		[Vector3(-9,2.24,-783),"Zhixin side to DaoYuan stair"],[Vector3(-16,2.24,-783),"plus Z stair foot"],
		[Vector3(-40,4.64,-783),"plus Z stair ascent"],[Vector3(-41,4.64,-805),"brick forecourt to portal"],
		[Vector3(-47,5.12,-805),"three entry risers"],[Vector3(-53,5.12,-805),"glazed door vestibule"],
		[Vector3(-47,5.12,-805),"vestibule return"],[Vector3(-41,4.64,-805),"entry risers descent"],
		[Vector3(-41,4.64,-827),"minus Z upper landing"],[Vector3(-16,2.24,-827),"minus Z stair descent"],
		[Vector3(-9,2.24,-827),"street return"],[Vector3(-9,2.24,-839),"old gate road junction"],
		[Vector3(0,2.24,-839),"sports approach crossing"],[Vector3(0,2.24,-851),"sports entrance apron"]])
	await fixture(Vector3(-41,4.94,-827),[
		[Vector3(-41,4.64,-830.8),"upper side path alignment"],[Vector3(-94,4.64,-830.8),"minus Z side passage"],
		[Vector3(-94,4.64,-779.2),"rear upper passage"],[Vector3(-41,4.64,-779.2),"plus Z side passage"],
		[Vector3(-41,4.64,-783),"side path back to stair"],[Vector3(-16,2.24,-783),"plus Z stair descent"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"DaoYuan raised public forecourt,entry and side paths;fitted scales and hidden interiors are not verified"}
	FileAccess.open("res://tests/artifacts/daoyuan_terrace_v55.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("DAOYUAN_TERRACE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
