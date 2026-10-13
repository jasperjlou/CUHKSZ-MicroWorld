extends "res://tests/LibraryLowerRearV150.gd"
const Grey209=preload("res://world/visual_campus/LibraryGreyEntryStair.gd")
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var ps:=Grey209.points();var route:Array=[]
	for i in ps.size():route.append([wp(ps[i].x,ps[i].y,ps[i].z),"grey stair ascent "+str(i)])
	for p in [Vector3(-38,4.4,ps[-1].z),Vector3(-38,4.4,21.5),Vector3(-41,4.4,22)]:route.append([wp(p.x,p.y,p.z),"side gallery to covered link "+str(p)])
	route.append([Vector3(56,6.64,-350),"covered link toward student centre"])
	route.append([Vector3(56,6.64,-366),"covered link before student facade"])
	route.append([Vector3(56,6.64,-375),"existing student2Fportal"])
	route.append([Vector3(56,6.64,-350),"return along covered link"])
	route.append([wp(-41,4.4,22),"return side gallery corner"])
	route.append([wp(-38,4.4,21.5),"return side gallery turn"])
	route.append([wp(-38,4.4,ps[-1].z),"return stair landing approach"])
	for i in range(ps.size()-1,-1,-1):route.append([wp(ps[i].x,ps[i].y,ps[i].z),"grey stair descent "+str(i)])
	route.append([wp(ps[0].x+2,0,ps[0].z),"G apron return"])
	await fixture(wp(ps[0].x+2,.3,ps[0].z),route)
	var checks:Array=[]
	var m:Vector3=(ps[0]+ps[1])/2
	probe(wp(m.x,m.y+.7,m.z),wp(m.x,m.y+.7,m.z+1.3),true,"stair outer guard",checks)
	probe(wp(m.x,m.y+.7,m.z),wp(m.x,m.y+.7,m.z-1.3),true,"stair inner guard",checks)
	probe(wp(m.x,m.y+.2,m.z),wp(m.x,m.y+2.25,m.z),false,"lower flight overhead clearance",checks)
	root.disable_3d=false;await frames(12)
	await capture("library-grey-stair-v209-foot",wp(ps[0].x+4,1.8,ps[0].z+4),wp(ps[2].x,3.2,ps[2].z))
	await capture("library-grey-stair-v209-top",wp(ps[-1].x-1,6,ps[-1].z+3),wp(ps[0].x,1,ps[0].z))
	await capture("library-grey-stair-v209-link",Vector3(63,11,-325),Vector3(56,7,-375))
	FileAccess.open("res://tests/artifacts/library_grey_stair_v209.json",FileAccess.WRITE).store_string(JSON.stringify({"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"scope":"new grey shortcut stair and existing sidegallery/student connector;historical gallery endpoint remains fitted"},"\t"))
	print("LIBRARY_GREY_STAIR_V209 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
