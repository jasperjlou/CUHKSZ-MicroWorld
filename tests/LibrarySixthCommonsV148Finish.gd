extends "res://tests/LibrarySixthCommonsV148.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await fixture(door_point(602)+Vector3.UP*.3,[[door_point(0),"row602 to isolated room actual end door"],[door_point(602),"isolated room return to602"],[door_point(603),"602 to603 retained aisle"]])
	var checks:Array=[];var door:Node3D
	for node:Node3D in world.find_children("CommonsDoor*","Node3D",true,false):
		if node.get_meta("room_id",-1)==0:door=node;break
	probe(door_point(0)+Vector3.UP*.15,door_point(0)-Vector3.UP*.15,true,"isolated door has floor",checks)
	probe(door.to_global(Vector3(0,1.2,.5)),door.to_global(Vector3(0,1.2,-.5)),true,"isolated leaf closed",checks)
	probe(door.to_global(Vector3(-.4,1.2,.9)),door.to_global(Vector3(.4,1.2,.9)),false,"isolated approach clear",checks)
	for p in [Vector3(-1.35,0,-1.35),Vector3(1.35,0,-1.35),Vector3(1.35,0,1.35),Vector3(-1.35,0,1.35)]:
		var w:Vector3=door.get_parent().to_global(p);probe(w+Vector3.UP*.15,w-Vector3.UP*.15,true,"isolated room corner support "+str(p),checks)
	await capture("library-commons-v148-glass-final",p6(895,650,22.45),p6(858,445,22.35))
	await capture("library-commons-v148-lounge-final",p6(960,650,22.45),p6(1080,740,22.35))
	await capture("library-commons-v148-front-final",door_point(602)+Vector3.UP*1.7,door_point(0)+Vector3.UP*1.65)
	FileAccess.open("res://tests/artifacts/library_sixth_commons_v148_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Changed isolated room end door and corner support;only materials changed elsewhere"},"\t"))
	print("LIBRARY_COMMONS_V148_FINISH ",JSON.stringify({"legs":legs.size(),"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
