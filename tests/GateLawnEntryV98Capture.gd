extends "res://tests/TeachingAArcadeV97Capture.gd"

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await fixture(Vector3(-25,2.54,-114),[
		[Vector3(-25,2.24,-132.75),"along planting front to TA portal gap"],
		[Vector3(-35,2.24,-132.75),"across unplanted TA entry gap"],
		[Vector3(-40,2.24,-132.75),"canopy join existing accepted route"]])
	FileAccess.open("res://tests/artifacts/gate_lawn_v98_entry.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"failures":failures,"fixtures":1,"no_teleport_within_fixture":true},"\t"))
	quit(0 if failures.is_empty() else 1)
