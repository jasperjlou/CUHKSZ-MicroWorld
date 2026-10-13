extends "res://tests/CourtyardRefinementCapture.gd"
const W195:=preload("res://world/visual_campus/UpperRearWoodland.gd")
const C195:=preload("res://world/visual_campus/LibraryRearCanopy.gd")
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for p:Vector2 in [Vector2(137,-220),Vector2(130.4,-242),Vector2(152,-180),Vector2(162,-180),Vector2(124,-180)]:
		var valid:bool=not W195.contains(p.x,p.y);checks.append({"case":"road/waiting/garden clear "+str(p),"valid":valid})
		if not valid:failures.append("woodland covers public anchor "+str(p))
	var n:Node=world.get_node("UpperRearWoodlandV195")
	var free:bool=n.find_children("*","CollisionShape3D",true,false).is_empty();checks.append({"case":"new planting no hidden collision","valid":free})
	if not free:failures.append("planting collision")
	await capture("upper-woodland-v195-waiting",Vector3(130.4,C195.level()+1.7,-246),Vector3(152,14,-218))
	await capture("upper-woodland-v195-bend",Vector3(137,world.builder.height(137,-222)+1.7,-222),Vector3(167,19,-204))
	await capture("upper-woodland-v195-garden",Vector3(126,16.5,-180),Vector3(153,18,-180))
	await capture("upper-woodland-v195-teaching-a",Vector3(-125,0,-85),Vector3(-125,0,-148))
	await capture("upper-woodland-v195-teaching-b",Vector3(-135.12,-.5,-179),Vector3(-150,0,-210))
	FileAccess.open("res://tests/artifacts/upper_rear_woodland_v195.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"checks":checks,"counts":n.get_meta("counts"),"captures":captures,"failures":failures,"scope":"Upper rear planted transition only;terrain coordinates unchanged;teaching captures are inspection not new modeling acceptance"},"\t"))
	quit(0 if failures.is_empty() else 1)
