extends "res://tests/LibraryUpperPlanV110.gd"
const Entry=preload("res://world/visual_campus/LibraryEntryPavilion.gd")
const Lower=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
func ep(x:float,z:float,y:float=4.4)->Vector3:
	var p:=Entry.dp(x,z,y);return wp(p.x,p.y,p.z)
func map2(x:float,z:float,y:float=4.4)->Vector3:
	var p:=Lower.point2(x,z,y);return wp(p.x,p.y,p.z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-entry-pavilion-v116-overview",wp(38,15,65),wp(21,7,7))
	await capture("library-entry-pavilion-v116-door",ep(0,5.5,6.2),ep(0,-6,6.2))
	await capture("library-entry-pavilion-v116-exhibition",map2(1310,510,6.2),map2(1590,610,6.1))
	await capture("library-entry-pavilion-v116-end",wp(57,8,23),map2(1610,650,7))
	var route:Array=[]
	for p in [Vector3(5,0,30),Vector3(11,2.2,24),Vector3(17,4.4,18)]:route.append([wp(p.x,p.y,p.z),"retained exterior stair "+str(p)])
	for p in [[0,2],[0,-2],[0,-4]]:route.append([ep(p[0],p[1]),"new diagonal threshold "+str(p)])
	for p in [[1210,650],[1300,590],[1420,610],[1520,640],[1610,650],[1680,595],[1610,650],[1520,640],[1420,610],[1300,590],[1210,650]]:route.append([map2(p[0],p[1]),"registered2F exhibition "+str(p)])
	for p in [[0,-4],[0,-2],[0,2]]:route.append([ep(p[0],p[1]),"entry return "+str(p)])
	for p in [Vector3(17,4.4,18),Vector3(11,2.2,24),Vector3(5,0,30),Vector3(2,0,33)]:route.append([wp(p.x,p.y,p.z),"stair return "+str(p)])
	await fixture(wp(2,.3,33),route)
	var checks:Array=[]
	for item in [[ep(0,1,6),ep(0,-1,6),false,"open registered door"],[ep(4,1,6),ep(4,-1,6),true,"closed side glazing"],[map2(1670,600,4.7),map2(1670,600,4.2),true,"exhibition tip restored floor"],[wp(33,1.5,20),wp(33,1.5,22),false,"retired freestanding pavilion wall"]]:
		var q=PhysicsRayQueryParameters3D.create(item[0],item[1]);q.exclude=[world.player.get_rid()];var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=(not hit.is_empty())==item[2]
		checks.append({"case":item[3],"valid":valid});if not valid:failures.append(item[3])
	var report={"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Registered2F doorway/exhibition and retained temporary approach; exterior stair/grade and2F3F facade discrepancy explicitly unresolved"}
	FileAccess.open("res://tests/artifacts/library_entry_pavilion_v116.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_ENTRY_PAVILION ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
