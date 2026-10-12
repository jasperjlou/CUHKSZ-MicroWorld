extends "res://tests/LibraryRareV113.gd"
func probe(a:Vector3,b:Vector3,expected:bool,label:String,checks:Array)->void:
	var q:=PhysicsRayQueryParameters3D.create(a,b);q.exclude=[world.player.get_rid()]
	var hit:=world.get_world_3d().direct_space_state.intersect_ray(q)
	var valid:bool=not hit.is_empty() if expected else hit.is_empty()
	checks.append({"case":label,"valid":valid})
	if not valid:failures.append(label)

func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var route:Array=[]
	for i in range(4):
		var y:float=Core.LEVELS[i];var top:float=Core.LEVELS[i+1];var half:float=(y+top)/2
		for p in [Vector3(-1.45,y,-3.8),Vector3(-1.45,half,3.8),Vector3(1.45,half,3.8),Vector3(1.45,top,-3.8),Vector3(5.35,top,-3.8),Vector3(1.45,top,-3.8)]:route.append([lp(p.x,p.y,p.z),"left core ascent/exit "+str(p)])
	for i in range(4,0,-1):
		var y:float=Core.LEVELS[i];var below:float=Core.LEVELS[i-1];var half:float=(y+below)/2
		for p in [Vector3(1.45,half,3.8),Vector3(-1.45,half,3.8),Vector3(-1.45,below,-3.8),Vector3(1.45,below,-3.8)]:route.append([lp(p.x,p.y,p.z),"left core descent "+str(p)])
	await fixture(lp(1.45,.3,-3.8),route)
	var room:Array=[]
	for p in [[466,977],[410,977],[360,977],[290,977],[215,977],[215,995],[290,995],[360,977],[410,977],[466,977],[466,930]]:room.append([p5(p[0],p[1],16.8),"rare shared-wall aisle "+str(p)])
	await fixture(p5(466,930,17.1),room)
	var sixth:Array=[]
	for p in [[870,825],[860,690],[820,650],[900,650],[950,730],[1020,760],[1010,680],[990,625],[970,590],[970,460],[950,400],[800,400],[790,490],[790,640],[860,690],[870,825]]:sixth.append([p6(p[0],p[1],20.8),"6F registered room-group aisle "+str(p)])
	await fixture(p6(870,825,21.1),sixth)
	world.player.set_physics_process(false)
	var checks:Array=[]
	for y in Core.LEVELS:
		probe(lp(0,y+1.6,7.3),lp(0,y+1.6,8.1),true,"core end enclosure "+str(y),checks)
		if y>0:probe(lp(-1.45,y+.15,0),lp(-1.45,y-.15,0),false,"aligned shaft cut "+str(y),checks)
	probe(p5(240,968,18.2),p5(335,968,18.2),false,"old core intrusion removed",checks)
	probe(p5(288,940,18.2),p5(288,962,18.2),true,"shared wall retained",checks)
	probe(p5(466,938,18.2),p5(466,977,18.2),false,"rare doorway open",checks)
	for mesh:Node3D in world.find_children("ResearchCell*","Node3D",true,false):
		if not str(mesh.get_path()).contains("LibraryRegisteredUpperV110"):continue
		if mesh.global_position.y<22:continue
		probe(mesh.global_position+Vector3.UP*.2,mesh.global_position-Vector3.UP*.2,true,"6F room supported "+mesh.name,checks)
	await capture("library-core-v147-room",pp(540,850,18.5),pp(350,900,18.2))
	await capture("library-core-v147-shared-wall",p5(360,1000,18.45),p5(275,950,18.3))
	await capture("library-core-v147-upper-door",lp(7,18.5,-4),lp(0,18.5,-3.8))
	await capture("library-core-v147-sixth",p6(955,650,22.5),p6(845,425,22.3))
	FileAccess.open("res://tests/artifacts/library_core_boundary_v147.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":3,"scope":"G-5F relocated left core/side exits,5F shared-wall aisle,6F registered groups;not full library or campus"},"\t"))
	print("LIBRARY_CORE_V147 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}))
	quit(0 if failures.is_empty() else 1)
