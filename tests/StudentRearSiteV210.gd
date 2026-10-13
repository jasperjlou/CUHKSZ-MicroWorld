extends "res://tests/LibraryLowerRearV150.gd"
const Student210=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for v:float in [447.5,580.]:
		var p:=Student210.world(924,v)
		probe(p+Vector3(-1,1.5,0),p+Vector3(1,1.5,0),false,"rear door remains open "+str(v),checks)
		probe(Vector3(112.9,3.2,p.z),Vector3(112.9,2,p.z),true,"apron terrain support "+str(v),checks)
	var route:Array=[]
	for p in [[127,-350],[120,-365],[116,-372],[116,-399.238],[110.5,-399.238],[102,-399.238],[110.5,-399.238],[116,-399.238],[116,-408.85],[110.5,-408.85],[102,-408.85],[110.5,-408.85],[110.5,-420],[110.5,-428],[115,-475],[110.5,-428],[110.5,-420],[110.5,-372],[110.5,-365],[122,-345]]:
		route.append([Vector3(p[0],2.34,p[1]),"rear court, doors and pedestrian return "+str(p)])
	await fixture(Vector3(132,6.5,-330),route)
	root.disable_3d=false;await frames(12)
	await capture("student-rear-v210-doors",Vector3(118,7,-420),Vector3(104,4,-400))
	await capture("student-rear-v210-first-mouth",Vector3(116,4,-396),Vector3(103,3.5,-399.238))
	await capture("student-rear-v210-second-mouth",Vector3(116,3.9,-412),Vector3(103,3.3,-408.85))
	await capture("student-rear-v210-descent",Vector3(130,8,-344),Vector3(109,3,-372))
	FileAccess.open("res://tests/artifacts/student_rear_site_v210.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"scope":"library descent, two plan-based rear doors and Shaw pedestrian junction; fitted dimensions"},"\t"))
	print("STUDENT_REAR_SITE_V210 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
