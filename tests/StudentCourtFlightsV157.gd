extends "res://tests/StudentCoreV154Clearance.gd"
const Flights157=preload("res://world/visual_campus/StudentCourtStairs.gd")
func stair_path(s:Dictionary,up:bool,lane:float)->Array:
	var v:float=lerpf(s.v0,s.v1,lane);var path:Array=[];var points:Array=[]
	points.append([s.u0-10,v,s.low+.015]);points.append([s.u0,v,s.low+.015])
	if s.landing>0:
		var mid:float=(s.u0+s.u1)/2;var inset:float=s.landing*Plan153.PIXELS_PER_METRE/2
		points.append([mid-inset,v,(s.low+s.high)/2]);points.append([mid+inset,v,(s.low+s.high)/2])
	points.append([s.u1,v,s.high+.015]);points.append([s.u1+18,v,s.high+.015])
	if not up:points.reverse()
	for q in points:path.append([pp(q[0],q[1],q[2]),("up " if up else "down ")+str(q)])
	return path
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var s:=Flights157.flights();var checks:Array=[]
	for i in s.size():
		var f:Dictionary=s[i];var v:float=(f.v0+f.v1)/2
		probe(pp(f.u0+15,v,f.high-.1),pp(f.u0+15,v,f.high+.1),false,"court opening "+str(i),checks)
		if f.landing>0:
			var u:float=(f.u0+f.u1)/2;var y:float=(f.low+f.high)/2
			probe(pp(u,lerpf(f.v0,f.v1,.25),y+.2),pp(u,lerpf(f.v0,f.v1,.25),y-.2),true,"mid landing floor "+str(i),checks)
			probe(pp(u,v-5,y+.55),pp(u,v+5,y+.55),true,"opaque central guard "+str(i),checks)
	probe(pp(s[0].u0-10,510,4.9),pp(s[0].u0+8,510,4.9),true,"upper first-well end guard",checks)
	probe(pp(790,270,14),pp(790,215,14),false,"fourth court to rear wing",checks)
	var route:Array=[];route.append_array(stair_path(s[0],true,.5))
	for q in [[350,510,4.4],[350,395,4.4]]:route.append([pp(q[0],q[1],q[2]),"first court bypass "+str(q)])
	route.append_array(stair_path(s[1],true,.25))
	for q in [[580,395,8.8],[580,310,8.8],[580,255,8.8]]:route.append([pp(q[0],q[1],q[2]),"middle court aisle "+str(q)])
	route.append_array(stair_path(s[2],true,.25))
	for q in [[780,320,12.4],[800,220,12.4],[720,200,12.4],[720,95,12.4],[720,66,12.415],[720,95,12.4],[800,220,12.4],[780,320,12.4],[750,320,12.4],[750,284,12.4]]:route.append([pp(q[0],q[1],q[2]),"fourth court rear core circuit "+str(q)])
	route.append_array(stair_path(s[2],false,.75))
	for q in [[580,284,8.8],[580,395,8.8],[574,440,8.8]]:route.append([pp(q[0],q[1],q[2]),"middle descent approach "+str(q)])
	route.append_array(stair_path(s[1],false,.75))
	for q in [[350,440,4.4],[350,510,4.4]]:route.append([pp(q[0],q[1],q[2]),"first descent approach "+str(q)])
	route.append_array(stair_path(s[0],false,.5))
	route.append([pp(185,510,.075),"return to ground"])
	await fixture(pp(185,510,.375),route)
	await fixture(Vector3(36,6.94,-400),[[pp(85,440,4.4),"promenade opening"],[pp(145,440,4.4),"front column bypass"],[pp(200,430,4.4),"before new stairwell"],[pp(330,430,4.4),"north of relocated stairwell"],[pp(350,395,4.4),"first court interface"]])
	await capture("student-v157-first-flight",pp(155,620,7.5),pp(270,510,2.8))
	await capture("student-v157-middle-flight",pp(360,515,7),pp(510,426,7))
	await capture("student-v157-upper-flight",pp(530,355,11),pp(665,270,11))
	await capture("student-v157-core-link",pp(800,365,14.1),pp(780,125,13.8))
	await capture("student-v157-courts",pp(160,420,14),pp(730,290,11))
	FileAccess.open("res://tests/artifacts/student_court_flights_v157.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":2,"scope":"Three court flights ascent/descent, fourth court-rear core loop and relocated first-well promenade; historic plan fitted to current model heights."},"\t"))
	print("STUDENT_COURT_FLIGHTS_V157 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
