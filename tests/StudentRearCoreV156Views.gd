extends "res://tests/StudentRearCoreV156.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("student-v156-core-final",pp(720,56,10.55),pp(776,40,11.25))
	await capture("student-v156-overview-final",pp(550,400,29),pp(530,200,16))
	FileAccess.open("res://tests/artifacts/student_rear_core_v156_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"physical_legs":0,"scope":"Core camera and noncolliding25mm roof finish only; reuse137walks/24checks."},"\t"))
	print("STUDENT_REAR_CORE_V156_VIEWS ",captures.size());quit()
