extends "res://tests/StudentPondEntryV163.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("student-v163-entry-final",pp(367,-115,3.2),pp(367,55,4.1))
	await capture("student-v163-wide-final",Vector3(62,4.6,-335),Vector3(84,11,-372))
	FileAccess.open("res://tests/artifacts/student_pond_entry_finish_v163.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"failures":failures,"physical_legs":0,"scope":"Side-wall front inset7cm and noncolliding yellow finish only; accepted central walking/cap geometry unaffected."},"\t"))
	print("STUDENT_POND_ENTRY_FINISH_V163 ",captures.size());quit(0 if failures.is_empty() else 1)
