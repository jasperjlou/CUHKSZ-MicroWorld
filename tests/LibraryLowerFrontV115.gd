extends "res://tests/LibraryUpperPlanV110.gd"
const LowerPlan=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
func gp(x:float,z:float,y:float=0)->Vector3:
	var p:=LowerPlan.point1(x,z,y);return wp(p.x,p.y,p.z)
func tp(x:float,z:float,y:float=8.8)->Vector3:
	var p:=LowerPlan.point3(x,z,y);return wp(p.x,p.y,p.z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-lower-front-v115-shell",wp(-22,16,98),wp(-15,13,23))
	await capture("library-lower-front-v115-entry",wp(-9,1.8,21),gp(555,865,1.7))
	await capture("library-lower-front-v115-arrival",wp(-12,1.8,10),wp(-20,1.7,9))
	await capture("library-lower-front-v115-third",tp(590,980,10.5),tp(810,1160,10.4))
	var ground:Array=[]
	for p in [Vector3(-12,0,21),Vector3(-12,0,18)]:ground.append([wp(p.x,p.y,p.z),"recessedG outside approach "+str(p)])
	ground.append([gp(575,895),"mapG threshold"])
	for p in [Vector3(-12,0,10),Vector3(-16,0,10),Vector3(-16,0,6),Vector3(-18,0,4),Vector3(-23,0,4),Vector3(-23,0,9),Vector3(-23,0,4),Vector3(-16,0,4),Vector3(-12,0,10)]:ground.append([wp(p.x,p.y,p.z),"mapG exhibit/core aisle "+str(p)])
	ground.append([gp(575,895),"G return threshold"]);ground.append([wp(-12,0,21),"G forecourt return"])
	await fixture(wp(-12,.3,29),ground)
	var upper:Array=[]
	for p in [[450,980],[550,980],[650,1020],[750,1090],[850,1190],[900,1210],[850,1190],[750,1090],[650,1020],[550,980],[450,980]]:upper.append([tp(p[0],p[1]),"independent3Ffront "+str(p)])
	await fixture(tp(420,980,9.1),upper)
	var checks:Array=[]
	for item in [[wp(-25,9.0,27),wp(-25,8.65,27),false,"retired old projecting3Fslab"],[tp(850,1190,9),tp(850,1190,8.65),true,"new3F curved front slab"],[gp(575,915,1.6),gp(575,870,1.6),false,"recessedG door open"],[gp(450,895,1.6),gp(450,860,1.6),true,"G closedglass"]]:
		var q=PhysicsRayQueryParameters3D.create(item[0],item[1]);q.exclude=[world.player.get_rid()];var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=(not hit.is_empty())==item[2]
		checks.append({"case":item[3],"valid":valid});if not valid:failures.append(item[3])
	var report={"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":2,"scope":"newGfront/arrival and independent3Ffront only;2F/stair/pavilion/pool alignment remains partial"}
	FileAccess.open("res://tests/artifacts/library_lower_front_v115.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_LOWER_FRONT ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
