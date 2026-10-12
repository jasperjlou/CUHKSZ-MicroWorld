extends "res://tests/LibraryCoreBoundaryV147.gd"
const Roof=preload("res://world/visual_campus/LibraryRoofLantern.gd")
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for tip:Node3D in world.find_children("LibraryRearTipV149_*","Node3D",true,false):
		for y in [14.4,18.4,22.4]:
			for x in [-3.0,3.0]:
				probe(tip.to_global(Vector3(x,y,-2)),tip.to_global(Vector3(x,y,-.5)),true,"recessed closed pane "+tip.name+str([x,y]),checks)
			probe(tip.to_global(Vector3(-3,y,-.5)),tip.to_global(Vector3(3,y,-.5)),false,"old flush plane removed "+tip.name+str(y),checks)
	for p in [[430,640],[600,640],[850,740],[690,936]]:
		var base:=Plan.point(p[0],p[1]);var y:float=Plan.roof_height(Vector2(base.x,base.z))-.24
		probe(wp(base.x-.7,y,base.z),wp(base.x+.7,y,base.z),true,"support reaches roof "+str(p),checks)
		probe(wp(base.x,9,base.z),wp(base.x,8.5,base.z),true,"existing support foot "+str(p),checks)
	var route:Array=[]
	for p in [[350,155],[350,105],[350,65],[450,65],[510,65],[510,105],[510,155]]:route.append([pp(p[0],p[1],12.8),"left rear reading window aisle "+str(p)])
	await fixture(pp(350,195,13.1),route)
	var right:Array=[]
	for p in [[1135,250],[1170,215],[1210,250],[1250,290],[1290,330],[1285,380]]:right.append([pp(p[0],p[1],12.8),"right rear reading window aisle "+str(p)])
	await fixture(pp(1135,300,13.1),right)
	await capture("library-roof-v149-overall",wp(-36,57,94),wp(-6,17,4))
	await capture("library-roof-v149-lantern",pp(475,940,36),pp(655,770,28.1))
	await capture("library-roof-v149-rear-left",pp(345,-310,19.5),pp(405,55,19.5))
	await capture("library-roof-v149-rear-right",pp(1435,80,20.5),pp(1240,255,19.5))
	await capture("library-roof-v149-support",pp(555,610,23.1),pp(600,640,26.2))
	var report={"version":world.data.version,"checks":checks,"physical_legs":legs,"fixtures":2,"captures":captures,"failures":failures,"scope":"Changed upper rear glazing and existing support tops;roof visual only;not complete column grid or lower rear envelope"}
	FileAccess.open("res://tests/artifacts/library_roof_rear_v149.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_ROOF_REAR_V149 ",JSON.stringify({"checks":checks.size(),"legs":legs.size(),"failures":failures}))
	quit(0 if failures.is_empty() else 1)
