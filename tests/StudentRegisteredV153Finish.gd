extends "res://tests/StudentRegisteredV153.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(pp(265,5,5.9),pp(265,50,5.9),false,"fitted library gallery portal",checks)
	probe(pp(320,5,5.9),pp(320,50,5.9),true,"neighbour library-side bay closed",checks)
	probe(pp(265,24,7.7),pp(265,24,8.1),true,"gallery lintel",checks)
	probe(pp(900,580,1.5),pp(945,580,1.5),false,"second rear door remains open",checks)
	await fixture(pp(620,350,9.1),[[pp(565,315,8.8),"upper flight end approach"],[pp(565,267,8.8),"around upper side rail"],[pp(590,267,8.8),"upper stair foot"],[pp(750,267,12.4),"upper terrace ascent"],[pp(800,320,12.4),"upper terrace clear aisle"],[pp(780,267,12.4),"upper return landing"],[pp(590,267,8.8),"upper terrace descent"],[pp(565,267,8.8),"upper foot exit"]])
	await fixture(Vector3(56,6.94,-360),[[Vector3(56,6.64,-382),"library upper link through fitted portal"],[pp(280,230,4.4),"north wing gallery"],[pp(280,270,4.4),"gallery to first court"],[pp(350,300,4.4),"first court north aisle"]])
	await fixture(pp(890,580,.375),[[pp(945,580,.075),"second rear entry out"],[Vector3(110.5,2.34,-408.85),"second doorway pavement"],[Vector3(110.5,2.34,-428),"rear pedestrian continuation"],[Vector3(115,2.34,-475),"retained Shaw walk junction"]])
	await fixture(Vector3(127,2.54,-350),[[Vector3(116,2.34,-372),"new rear road elbow"],[Vector3(116,2.34,-400),"road past main door"],[Vector3(110.5,2.34,-400),"showcase pavement"],[Vector3(110.5,2.34,-399.238),"showcase door approach"],[Vector3(102,2.315,-399.238),"showcase rear lobby"],[Vector3(110.5,2.34,-399.238),"showcase lobby exit"],[Vector3(110.5,2.34,-428),"showcase pavement return"],[Vector3(116,2.34,-428),"road rejoin"],[Vector3(120,2.34,-475),"retained Shaw avenue junction"]])
	await capture("student-v153-gallery-final",Vector3(56,9,-357),pp(270,175,5.8))
	await capture("student-v153-upper-final",pp(565,345,11.3),pp(810,267,13.4))
	FileAccess.open("res://tests/artifacts/student_registered_v153_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":4,"scope":"Changed gallery portal, corrected stair approach and both rear road connections only; no surveyed door/height claim"},"\t"))
	print("STUDENT_V153_FINISH ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
