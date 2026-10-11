extends "res://tests/LibraryRearRoadCapture.gd"
const Bank := preload("res://world/visual_campus/RearRoadBank.gd")
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var toe:=Bank.toe(Bank.STAIR_Z,world.builder.rear_route);var y:=Bank.road_height(Bank.STAIR_Z)
	await capture("library-rear-bank-stair-final",Vector3(toe-7,y+2,Bank.STAIR_Z),Vector3(toe+5,y+2.7,Bank.STAIR_Z))
	await capture("library-rear-overall-final",Vector3(176,65,-354),Vector3(109,9,-290))
	FileAccess.open("res://tests/artifacts/library_rear_frame_visual.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"failures":failures,"build_ms":world.built_ms,"scope":"local terrain under stair sampled at real stair edges; visual only, reuse physical follow-up"},"\t"))
	quit(0 if failures.is_empty() else 1)
