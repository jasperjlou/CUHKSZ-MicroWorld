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
	var route:Array=[];route.append_array(stair_path(s[0],true,.5))
	for q in [[350,510,4.4],[350,395,4.4]]:route.append([pp(q[0],q[1],q[2]),"first court bypass "+str(q)])
	route.append_array(stair_path(s[1],true,.25))
	for q in [[560,395,8.8],[560,310,8.8],[580,255,8.8]]:route.append([pp(q[0],q[1],q[2]),"middle court aisle "+str(q)])
	route.append_array(stair_path(s[2],true,.25))
	for q in [[780,320,12.4],[800,220,12.4],[720,200,12.4],[720,95,12.4],[720,66,12.415],[720,95,12.4],[800,220,12.4],[780,320,12.4],[750,320,12.4],[750,284,12.4]]:route.append([pp(q[0],q[1],q[2]),"fourth court rear core circuit "+str(q)])
	route.append_array(stair_path(s[2],false,.75))
	for q in [[560,284,8.8],[560,395,8.8],[574,440,8.8]]:route.append([pp(q[0],q[1],q[2]),"middle descent approach "+str(q)])
	route.append_array(stair_path(s[1],false,.75))
	for q in [[350,440,4.4],[350,510,4.4]]:route.append([pp(q[0],q[1],q[2]),"first descent approach "+str(q)])
	route.append_array(stair_path(s[0],false,.5))
	route.append([pp(185,510,.075),"return to ground"])
	route=route.slice(12)
	await fixture(pp(573.423645,412.199585,9.115),route)
	await capture("student-v157-first-final",pp(185,506,1.8),pp(315,506,4.8))
	await capture("student-v157-middle-final",pp(360,426,6.2),pp(555,426,8.0))
	await capture("student-v157-courts-final",pp(340,365,14),pp(730,300,12))
	FileAccess.open("res://tests/artifacts/student_court_flights_v157_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":1,"scope":"Three court flights ascent/descent, fourth court-rear core loop and relocated first-well promenade; historic plan fitted to current model heights."},"\t"))
	print("STUDENT_COURT_FLIGHTS_V157_FINISH ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
