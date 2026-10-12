extends "res://tests/StudentRegisteredV153.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(pp(367,40,4.55),pp(367,40,4.25),false,"two-storey mouth has no intermediate floor",checks)
	for y in [8.8,12.4]:
		probe(pp(367,40,y+.15),pp(367,40,y-.15),true,"photo-facing cap floor "+str(y),checks)
		probe(pp(367,130,y+.15),pp(367,130,y-.15),false,"inner lightwell remains open "+str(y),checks)
		probe(pp(367,70,y+.6),pp(367,90,y+.6),true,"cap lightwell edge guarded "+str(y),checks)
	probe(pp(367,70,1.5),pp(367,90,1.5),false,"recess ground door open",checks)
	probe(pp(367,70,5.8),pp(367,90,5.8),true,"recess upper glazing protects edge",checks)
	probe(pp(367,15,10),pp(367,30,10),true,"photo-facing upper enclosure",checks)
	var route:Array=[]
	for q in [[367,-10],[367,35],[367,65],[367,100],[270,100],[245,170],[118,170],[245,170],[270,100],[367,100],[367,65],[367,35],[367,-10],[310,-10]]:route.append([pp(q[0],q[1],.075),"pond entry public hall "+str(q)])
	await fixture(pp(310,-10,.35),route)
	await fixture(pp(270,120,4.7),[[pp(367,120,4.4),"second rear aisle"],[pp(367,90,4.4),"second protected glazing"],[pp(270,120,4.4),"second return"]])
	for y in [8.8,12.4]:await fixture(pp(270,45,y+.3),[[pp(367,45,y),"new cap across "+str(y)],[pp(450,45,y),"new cap side join "+str(y)],[pp(270,45,y),"cap return "+str(y)]])
	await capture("student-v163-pond-entry",pp(367,-115,3.2),pp(367,55,4.1))
	await capture("student-v163-recess",pp(370,28,1.8),pp(367,88,2.8))
	await capture("student-v163-cap-well",pp(360,42,10.5),pp(367,145,7.5))
	await capture("student-v163-pond-wide",Vector3(62,4.6,-335),Vector3(84,11,-372))
	FileAccess.open("res://tests/artifacts/student_pond_entry_v163.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":4,"scope":"Local photo-prioritized pond recess and cap plates,not resolved whole-building datum or historic plan exactness."},"\t"))
	print("STUDENT_POND_ENTRY_V163 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
