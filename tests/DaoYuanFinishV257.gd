extends "res://tests/CourtyardRefinementCapture.gd"
const D:=preload("res://world/visual_campus/DaoYuanGrade.gd")
func p(x:float,y:float,z:float)->Vector3:return D.registered(Vector3(x,y,z))
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("daoyuan-v257-final-rear-link",Vector3(-71,4.1,-689),Vector3(-74,4,-749))
	await capture("daoyuan-v257-final-stair-mouth",Vector3(-136,6.8,-756),Vector3(-140,4.7,-752))
	await fixture(p(-41,4.94,-805),[
		[p(-41,4.64,-783),"near rail corner"],[p(-16,2.24,-783),"near flight descent"],
		[p(-41,4.64,-783),"near flight return"],[p(-41,4.64,-827),"far rail corner"],
		[p(-16,2.24,-827),"far flight descent"],[p(-41,4.64,-827),"far flight return"]])
	FileAccess.open("res://tests/artifacts/daoyuan_finish_v257.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"collision_changed":"extended full-height guard to both stair endpoints","scope":"Final grass seam closure, channel termination and guard continuity;6 affected legs plus14 prior retained records"},"\t"))
	print("DAOYUAN_FINISH_V257 ",captures.size()," failures=",failures);quit(0 if failures.is_empty() else 1)
