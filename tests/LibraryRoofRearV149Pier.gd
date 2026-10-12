extends "res://tests/LibraryCoreBoundaryV147Finish.gd"
const Entry=preload("res://world/visual_campus/LibraryEntryLevels.gd")
func ep(x:float,z:float,y:float)->Vector3:
	var p:=Entry.horizontal(Vector3(x,0,z));return wp(p.x,y,p.z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[];var p:=Plan.point(865,754);var y:float=Plan.roof_height(Vector2(p.x,p.z))-.24
	probe(pp(850,740,9)-Vector3.RIGHT*.6,pp(850,740,9)+Vector3.RIGHT*.6,false,"old hanging base clear",checks)
	probe(wp(p.x-.7,y,p.z),wp(p.x+.7,y,p.z),true,"corrected pier roof joint",checks)
	for level in [8.8,12.8,16.8,20.8]:
		probe(wp(p.x-.7,level+.6,p.z),wp(p.x+.7,level+.6,p.z),true,"corrected pier collision "+str(level),checks)
	for dx in [-.35,.35]:
		for dz in [-.35,.35]:probe(wp(p.x+dx,8.96,p.z+dz),wp(p.x+dx,8.4,p.z+dz),true,"pier four-corner supporting slab "+str([dx,dz]),checks)
	var route:Array=[]
	for z in [-.5,1.5,4,7]:route.append([ep(-4.7,z,8.8),"3F beside corrected pier "+str(z)])
	await fixture(ep(-4.7,-2,9.1),route)
	await capture("library-roof-v149-column-foot-final",ep(-6,-1,10.5),pp(865,754,9))
	FileAccess.open("res://tests/artifacts/library_roof_rear_v149_pier.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"checks":checks,"physical_legs":legs,"captures":captures,"failures":failures,"fixtures":1},"\t"))
	print("LIBRARY_ROOF_PIER ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}))
	quit(0 if failures.is_empty() else 1)
