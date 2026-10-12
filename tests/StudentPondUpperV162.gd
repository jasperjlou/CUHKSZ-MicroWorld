extends "res://tests/StudentRearCoreV156.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for y in [17.4,21.0]:probe(fp(640,15,y),fp(640,27,y),true,"red screen retains edge "+str(y),checks)
	probe(fp(350,90,16.12),fp(350,90,15.88),false,"first upper notch not falsely floored",checks)
	probe(fp(640,90,16.12),fp(640,90,15.88),false,"rear upper void retained",checks)
	for y in [16.,19.6]:await fixture(fp(280,213,y+.3),[[fp(390,213,y),"front gallery "+str(y)],[fp(600,213,y),"middle gallery "+str(y)],[fp(720,213,y),"rear gallery "+str(y)]])
	await capture("student-v162-pond-wide",Vector3(62,5,-335),Vector3(83,12,-372))
	await capture("student-v162-upper-notch",fp(350,-60,20),fp(350,100,20))
	await capture("student-v162-red-screen",fp(680,-100,19.5),fp(730,24,19.5))
	await capture("student-v162-red-perforations",fp(640,24.5,20.8),fp(640,19,20.8))
	FileAccess.open("res://tests/artifacts/student_pond_upper_v162.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"checks":checks,"physical_legs":legs,"captures":captures,"failures":failures,"fixtures":2,"scope":"Upper-gallery interface and upper-screen visual batch; lower datum and pond entrances not accepted."},"\t"))
	print("STUDENT_POND_UPPER_V162 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
