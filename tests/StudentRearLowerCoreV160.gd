extends "res://tests/StudentRegisteredV153.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for y in [4.4,8.8]:
		probe(pp(880,484.5,y+.12),pp(880,484.5,y-.12),false,"lower core real slab hole "+str(y),checks)
	probe(pp(880,484.5,12.55),pp(880,484.5,12.25),true,"fourth court floor retained",checks)
	probe(pp(840,480,10.2),pp(840,460,10.2),true,"third core north enclosure",checks)
	for u in [815,878]:probe(pp(u,612,10.2),pp(u,588,10.2),false,"third service door "+str(u),checks)
	probe(pp(845,550,10.2),pp(862,550,10.2),true,"third service dividing wall",checks)
	probe(pp(815,612,5.8),pp(815,588,5.8),false,"service plan not repeated downstairs",checks)
	var route:Array=[]
	for q in [[770,480],[815,487],[840,487]]:route.append([pp(q[0],q[1],.075),"ground core approach "+str(q)])
	for low in [0.,4.4]:
		var high:float=low+4.4
		for q in [[840,475,low],[876,475,low+1.1],[908,475,low+2.2],[908,494,low+2.2],[876,494,low+3.3],[840,494,high],[840,487,high]]:route.append([pp(q[0],q[1],q[2]),"lower core ascent "+str(q)])
	for q in [[815,487],[780,487],[780,620],[815,620],[815,580],[815,620],[878,620],[878,580],[878,620],[780,620],[780,487],[840,487]]:route.append([pp(q[0],q[1],8.8),"third service circulation "+str(q)])
	for high in [8.8,4.4]:
		var low:float=high-4.4
		for q in [[840,494,high],[876,494,low+3.3],[908,494,low+2.2],[908,475,low+2.2],[876,475,low+1.1],[840,475,low],[840,487,low]]:route.append([pp(q[0],q[1],q[2]),"lower core descent "+str(q)])
	for q in [[815,487],[770,480],[750,420]]:route.append([pp(q[0],q[1],.075),"ground return "+str(q)])
	await fixture(pp(750,420,.35),route)
	await capture("student-v160-rear-lower",pp(810,490,1.9),pp(900,480,2.4))
	await capture("student-v160-stair",pp(840,475,1.9),pp(905,475,2.8))
	await capture("student-v160-third-service",pp(820,640,10.5),pp(852,540,10.8))
	await capture("student-v160-court-above",pp(750,460,14.1),pp(910,477,12.6))
	FileAccess.open("res://tests/artifacts/student_rear_lower_core_v160.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Lower separate core G-3F and third-floor service envelope; fourth-level floor retained, precise termination unverified."},"\t"))
	print("STUDENT_REAR_LOWER_V160 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
