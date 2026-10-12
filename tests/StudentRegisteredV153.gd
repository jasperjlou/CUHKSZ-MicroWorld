extends "res://tests/StudentLowerEntriesV151.gd"
const Plan153=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
func pp(u:float,v:float,y:float=0)->Vector3:return Plan153.world(u,v,y)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("student-v153-front",pp(-110,630,17),pp(480,360,10))
	await capture("student-v153-courts",pp(115,455,7),pp(800,290,14))
	await capture("student-v153-plan",pp(475,480,78),pp(475,360,0))
	await capture("student-v153-rear",pp(1130,800,12),pp(924,440,6))
	var checks:Array=[]
	probe(pp(900,447.5,1.5),pp(945,447.5,1.5),false,"rear main entrance",checks)
	probe(pp(900,580,1.5),pp(945,580,1.5),false,"rear second entrance",checks)
	probe(pp(425,400,1.5),pp(425,400,3),false,"diagnostic inside wall plane",checks)
	probe(pp(400,500,1.5),pp(445,500,1.5),false,"lower yellow door",checks)
	probe(pp(50,200,1.5),pp(100,200,1.5),true,"slanted projecting wing",checks)
	probe(pp(180,600,1.5),pp(245,600,1.5),true,"set-back opposite wing",checks)
	await fixture(Vector3(36,6.94,-400),[
		[pp(130,458,4.4),"front promenade to first court"],[pp(350,458,4.4),"first court crossing"],[pp(400,430,4.4),"middle stair foot"],[pp(555,430,8.8),"middle courtyard ascent"],[pp(620,350,8.8),"middle court bypass table"],[pp(590,315,8.8),"upper flight alignment"],[pp(590,267,8.8),"upper stair foot"],[pp(750,267,12.4),"upper terrace ascent"],[pp(800,320,12.4),"upper terrace clear aisle"]])
	await fixture(pp(100,528,.3),[[pp(110,528,.075),"ground stair foot"],[pp(285,528,4.4),"first court ascent"],[pp(320,528,4.4),"first court landing"],[pp(350,470,4.4),"first court return aisle"],[pp(130,458,4.4),"return to front promenade"]])
	await fixture(pp(400,500,.3),[[pp(450,500,.075),"yellow ground door enter"],[pp(600,500,.075),"retained ground hall"],[pp(750,480,.075),"rear hall approach"],[pp(800,447.5,.075),"rear lobby entrance"],[pp(890,447.5,.075),"rear lobby"],[pp(945,447.5,.075),"rear doorway out"],[Vector3(110.5,2.34,-399.238),"new pavement"],[Vector3(116,2.34,-400),"new road interface"]])
	await fixture(Vector3(56,6.94,-360),[[Vector3(56,6.64,-382),"library upper link enters corrected north wing"],[pp(280,230,4.4),"north wing gallery"],[pp(280,270,4.4),"gallery to first court"],[pp(350,300,4.4),"first court north aisle"]])
	FileAccess.open("res://tests/artifacts/student_registered_v153.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":4,"scope":"Rebuilt student massing, three courts, doors and local interfaces; independent fitted heights and placement, not whole-campus completion"},"\t"))
	print("STUDENT_V153 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
