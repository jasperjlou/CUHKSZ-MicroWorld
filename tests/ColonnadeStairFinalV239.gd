extends "res://tests/LibraryLowerRearV150.gd"
const Grey239=preload("res://world/visual_campus/LibraryGreyEntryStair.gd")
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var p:=Grey239.points()
	await capture("colonnade-stair-v239-final-foot",wp(p[0].x+3,1.8,p[0].z+.3),wp(p[2].x,3.2,p[2].z))
	await capture("colonnade-stair-v239-final-top",wp(p[-1].x-1,6,p[-1].z+.3),wp(p[0].x,1,p[0].z))
	FileAccess.open("res://tests/artifacts/colonnade_stair_v239_final.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"scope":"unobstructed final stair material views;no model/collision change since first pass"},"\t"))
	print("COLONNADE_STAIR_FINAL_V239 captures=",captures.size());quit()
