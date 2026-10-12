extends "res://tests/LibraryCoreBoundaryV147Finish.gd"
func door_point(id:int)->Vector3:
	for door:Node3D in world.find_children("CommonsDoor*","Node3D",true,false):
		if door.get_meta("room_id",-1)==id:return door.to_global(Vector3(0,0,.9))
	return Vector3.ZERO

func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var route:Array=[]
	for p in [[900,780],[900,650],[950,730],[1020,760],[1010,680],[990,625],[970,590],[970,460],[950,400],[800,400],[790,490],[790,640],[900,650],[900,780],[870,825]]:route.append([p6(p[0],p[1],20.8),"6F new commons outer aisle "+str(p)])
	await fixture(p6(870,825,21.1),route)
	var front:Array=[]
	for id in [603,604,605,604,603,602,0,602]:front.append([door_point(id),"front row and isolated envelope door "+str(id)])
	await fixture(door_point(602)+Vector3.UP*.3,front)
	var checks:Array=[];var ids:Array=[]
	for door:Node3D in world.find_children("CommonsDoor*","Node3D",true,false):
		var id:int=door.get_meta("room_id",-1);ids.append(id)
		var outside:=door.to_global(Vector3(0,0,.9))
		probe(outside+Vector3.UP*.15,outside-Vector3.UP*.15,true,"door approach floor "+str(id),checks)
		probe(door.to_global(Vector3(0,1.2,.5)),door.to_global(Vector3(0,1.2,-.5)),true,"closed glass leaf "+str(id),checks)
		probe(door.to_global(Vector3(-.4,1.2,.9)),door.to_global(Vector3(.4,1.2,.9)),false,"public approach clear "+str(id),checks)
	for cluster:Node3D in world.find_children("CommonsSharedCluster*","Node3D",true,false):
		probe(cluster.to_global(Vector3(.4,1.4,-.3)),cluster.to_global(Vector3(.4,1.4,.3)),true,"shared middle "+cluster.name,checks)
	for furniture:Node3D in world.find_children("CommonsRoundTable*","Node3D",true,false)+world.find_children("CommonsBurgundySofa*","Node3D",true,false):
		probe(furniture.global_position+Vector3.UP*.15,furniture.global_position-Vector3.UP*.15,true,"furniture supported "+str(furniture.global_position),checks)
	ids.sort();var expected:Array=[0]
	for i in range(602,631):expected.append(i)
	checks.append({"case":"29 numbered rooms and one unnumbered envelope","valid":ids==expected,"ids":ids})
	if ids!=expected:failures.append("room ids")
	probe(p5(466,938,18.2),p5(466,977,18.2),false,"renamed special collection doorway retained",checks)
	await capture("library-commons-v148-glass",p6(895,650,22.45),p6(858,445,22.35))
	await capture("library-commons-v148-lounge",p6(960,650,22.45),p6(1080,740,22.35))
	await capture("library-commons-v148-front-row",door_point(602)+Vector3.UP*1.7,door_point(605)+Vector3.UP*1.7)
	await capture("library-commons-v148-special-sign",p5(480,922,18.5),p5(447,949,18.55))
	FileAccess.open("res://tests/artifacts/library_sixth_commons_v148.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":2,"scope":"Commons exterior aisles/30 closed room fronts/shared partitions/furniture support;not room interiors or full campus"},"\t"))
	print("LIBRARY_COMMONS_V148 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
