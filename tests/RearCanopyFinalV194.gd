extends "res://tests/CourtyardRefinementCapture.gd"
const C194:=preload("res://world/visual_campus/LibraryRearCanopy.gd")
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("rear-v194-final-paving",Vector3(130.4,C194.level()+1.7,-246),Vector3(133.5,C194.level()+1.2,-239.8))
	FileAccess.open("res://tests/artifacts/rear_canopy_final_v194.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"failures":failures,"scope":"Remove previous visual paving overlap only;retain final collision milestone"},"\t"))
	quit(0 if failures.is_empty() else 1)
