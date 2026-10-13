extends "res://tests/StudentRegisteredV153.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(18)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	if DisplayServer.get_name()=="headless":
		# The split facade also borders the unchanged3F-to4F court stair.
		await fixture(pp(650,320,9.0),[[pp(590,320,8.8),"3F stair approach"],[pp(585,285,8.8),"upper flight foot"],[pp(750,285,12.4),"4F upper landing"],[pp(800,320,12.4),"4F court aisle"],[pp(750,285,12.4),"4F landing return"],[pp(585,285,8.8),"upper flight descent"],[pp(590,320,8.8),"3F return aisle"],[pp(650,320,8.8),"3F loop end"]])
		FileAccess.open("res://tests/artifacts/student_lotus_v224_upper_physical.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"failures":failures,"scope":"3F4F stair beside newly separated wall opening only"},"\t"))
		print("STUDENT_LOTUS_UPPER_V224 ",JSON.stringify({"legs":legs.size(),"failures":failures}));quit(0 if failures.is_empty() else 1);return
	await capture("student-lotus-v224-final-booth",pp(525,250,6.1),pp(565,330,5.5))
	await capture("student-lotus-v224-final-reveal",pp(650,215,6.1),pp(500,90,6.3))
	await capture("student-lotus-v224-final-ground",pp(650,200,1.75),pp(470,110,1.9))
	FileAccess.open("res://tests/artifacts/student_lotus_v224_finish_visual.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"scope":"Noncollision booth seating/foliage and1F2F inner window paint;33leg physical result unchanged"},"\t"))
	quit()
