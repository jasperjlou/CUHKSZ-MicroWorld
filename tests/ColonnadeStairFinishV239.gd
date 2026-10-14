extends "res://tests/LibraryLowerRearV150.gd"
const Grey239=preload("res://world/visual_campus/LibraryGreyEntryStair.gd")
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var p:=Grey239.points()
	await capture("colonnade-stair-v239-walk",Vector3(-24,4,-396.4),Vector3(25,3.8,-396.4))
	await capture("colonnade-stair-v239-junction",Vector3(4,4.4,-387),Vector3(1,2.40,-397))
	await capture("colonnade-stair-v239-stone",Vector3(-20,3.2,-397.6),Vector3(-15,2.4,-396.4))
	await capture("colonnade-stair-v239-foot",wp(p[0].x+4,1.8,p[0].z+4),wp(p[2].x,3.2,p[2].z))
	await capture("colonnade-stair-v239-top",wp(p[-1].x-1,6,p[-1].z+3),wp(p[0].x,1,p[0].z))
	FileAccess.open("res://tests/artifacts/colonnade_stair_v239.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"scope":"disjoint colonnade visual sheets and pale grey-stair finish;unchanged collisions,no new route evidence,no common-datum claim"},"\t"))
	print("COLONNADE_STAIR_V239 captures=",captures.size()," failures=",failures);quit(0 if failures.is_empty() else 1)
