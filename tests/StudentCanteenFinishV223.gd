extends "res://tests/StudentRegisteredV153.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(18)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	if DisplayServer.get_name()=="headless":
		#285 is part-way up the existing flight: the upper landing begins after u310.
		await fixture(pp(190,528,.2),[[pp(220,528,.075),"retained fitted stair mouth"],[pp(330,528,4.4),"actual upper landing"],[pp(350,470,4.4),"upper circulation"],[pp(350,365,4.4),"upper court retained"],[pp(350,528,4.4),"landing return"],[pp(220,528,.075),"stair descent"],[pp(190,528,.075),"arcade return"]])
	else:
		await capture("student-canteen-v223-final-room",pp(405,380,1.75),pp(575,305,2.45))
		await capture("student-canteen-v223-final-entry",pp(235,350,1.75),pp(550,340,2.05))
		await capture("student-canteen-v223-final-ceiling",pp(480,480,1.75),pp(520,350,3.30))
	var suffix:String="physical" if DisplayServer.get_name()=="headless" else "visual"
	FileAccess.open("res://tests/artifacts/student_canteen_v223_finish_"+suffix+".json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"failures":failures,"captures":captures,"scope":"Correct stair landing target; final1F visual details. Earlier28 dining route legs unchanged"},"\t"))
	print("STUDENT_CANTEEN_FINISH_V223 ",suffix," ",JSON.stringify({"legs":legs.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
