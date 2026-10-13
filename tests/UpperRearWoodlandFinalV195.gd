extends "res://tests/CourtyardRefinementCapture.gd"
const C195:=preload("res://world/visual_campus/LibraryRearCanopy.gd")
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("upper-woodland-v195-final-waiting",Vector3(130.4,C195.level()+1.7,-246),Vector3(152,14,-218))
	await capture("upper-woodland-v195-final-bend",Vector3(137,world.builder.height(137,-222)+1.7,-222),Vector3(167,19,-204))
	await capture("upper-woodland-v195-final-garden",Vector3(126,16.5,-180),Vector3(153,18,-180))
	await capture("upper-woodland-v195-upper-teaching-a",Vector3(-133,world.builder.height(-133,-110)+1.7,-110),Vector3(-195,4,-110))
	await capture("upper-woodland-v195-upper-teaching-b",Vector3(-148,world.builder.height(-148,-188)+1.7,-188),Vector3(-215,4,-212))
	FileAccess.open("res://tests/artifacts/upper_rear_woodland_final_v195.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"scope":"Final woodland views after preserving unrelated random streams;upper teaching views inspect existing outside context only","failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
