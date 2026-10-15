extends "res://tests/CourtyardRefinementCapture.gd"
const D:=preload("res://world/visual_campus/DaoYuanGrade.gd")
func p(x:float,y:float,z:float)->Vector3:return D.registered(Vector3(x,y,z))
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("daoyuan-v257-stair",p(-11,5.5,-778),p(-37,5,-790))
	await capture("daoyuan-v257-edge",p(-42,6.5,-792),p(-36,4.7,-806))
	await capture("daoyuan-v257-side",p(-82,6.6,-830),p(-39,5,-830))
	await capture("daoyuan-v257-rear-link",Vector3(-71,4.1,-689),Vector3(-74,4,-749))
	await fixture(p(-9,2.54,-783),[
		[p(-16,2.24,-783),"side stair foot"],[p(-40,4.64,-783),"side stair ascent"],
		[p(-41,4.64,-805),"brick edge route"],[p(-41,4.64,-827),"far upper landing"],
		[p(-94,4.64,-830.8),"side passage to rear"],[p(-94,4.64,-779.2),"rear upper passage"],
		[p(-41,4.64,-779.2),"side return"],[p(-41,4.64,-783),"return upper landing"],
		[p(-16,2.24,-783),"side stair descent"],[p(-9,2.24,-783),"street return"]])
	await fixture(Vector3(-71,2.54,-775),[
		[Vector3(-71,2.24,-690),"old-library rear aisle"],
		[Vector3(-76,2.24,-682),"branch junction"],
		[Vector3(-71,2.24,-700),"junction return"],
		[Vector3(-71,2.24,-775),"old-library rear return"]])
	FileAccess.open("res://tests/artifacts/daoyuan_connections_v257.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"DaoYuan existing side/rear fitted routes and old-library aisle; no new lower-plan registration or full-campus claim"},"\t"))
	print("DAOYUAN_V257 ",legs.size()," failures=",failures);quit(0 if failures.is_empty() else 1)
