extends "res://tests/ZhangArcadeV131.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	front=world.builder.buildings.zhang_lingbin.get_node("RetainedPhotoFrontage")
	await capture("zhang-arcade-v131-service",pt(-2,24.6,1.75),pt(-25,24.6,1.8))
	await capture("zhang-arcade-v131-wide",pt(-4,32.1,2.0),pt(-11,21.5,2.3))
	await capture("zhang-arcade-v131-glass",pt(6.0,24.3,1.72),pt(27,24.1,3.3))
	FileAccess.open("res://tests/artifacts/zhang_arcade_v131_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"scope":"visual-only correction of generic stone overlay at arcade intersection; collision unchanged"},"\t"))
	quit(0 if failures.is_empty() else 1)
