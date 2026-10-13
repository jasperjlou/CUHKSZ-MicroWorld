extends "res://tests/LibraryLowerRearV150.gd"
const Grey209=preload("res://world/visual_campus/LibraryGreyEntryStair.gd")
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var ps:=Grey209.points();var z:float=ps[-1].z;var checks:Array=[]
	probe(wp(-34.5,5.1,z),wp(-33.1,5.1,z),false,"upper landing rail opening clear",checks)
	for offset:float in [-1.6,1.6]:probe(wp(-34.5,5.1,z+offset),wp(-33.1,5.1,z+offset),true,"flanking edge remains guarded "+str(offset),checks)
	await capture("library-grey-stair-v209-accepted-foot",wp(ps[0].x+3,1.8,ps[0].z+.3),wp(ps[2].x,3.2,ps[2].z))
	await capture("library-grey-stair-v209-accepted-top",wp(ps[-1].x-1,6,ps[-1].z+.3),wp(ps[0].x,1,ps[0].z))
	FileAccess.open("res://tests/artifacts/library_grey_stair_v209_accepted.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"captures":captures,"failures":failures,"scope":"final trimmed rail opening and flanking guards; previous21legs precede guard replacement"},"\t"))
	print("LIBRARY_GREY_STAIR_V209_ACCEPTED ",JSON.stringify({"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
