extends "res://tests/TeachingAArcadeV97Capture.gd"

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var n:Node3D=world.builder.buildings.teaching_a.get_node("TeachingACad")
	await capture("ta-v97-stairs",n.to_global(Vector3(15.5,2,48.5)),n.to_global(Vector3(27,4.1,40.5)))
	await capture("ta-v97-gallery",n.to_global(Vector3(10,2,45)),n.to_global(Vector3(12,8,34)))
	await capture("ta-v97-arcade",n.to_global(Vector3(17,2,53)),n.to_global(Vector3(34,4,63)))
	FileAccess.open("res://tests/artifacts/teaching_a_arcade_views_finish_v97.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"change":"non-colliding table legs and gallery ceiling/lights only"},"\t"))
	quit(0 if failures.is_empty() else 1)
