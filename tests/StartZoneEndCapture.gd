extends "res://tests/StartZonePublicCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("zhi-xin",Vector3(-52,9,-694),Vector3(-115,9,-733))
	await capture("library-corner",Vector3(-87,4.3,-715),Vector3(-105,5.9,-697))
	print("START_ZONE_END_FINAL captures=",captures," failures=",failures," build_ms=",world.built_ms)
	quit(0 if failures.is_empty() else 1)
