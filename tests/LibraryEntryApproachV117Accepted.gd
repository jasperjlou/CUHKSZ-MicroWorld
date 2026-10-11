extends "res://tests/LibraryEntryPavilionV116Final.gd"
const Approach=preload("res://world/visual_campus/LibraryEntryApproach.gd")
func ap(x:float,z:float,y:float=-100)->Vector3:
	var p:Vector3=Approach.point(x,z,Approach.surface_y(z) if y==-100 else y);return wp(p.x,p.y,p.z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-entry-approach-v117-accepted-front",ap(-12,47,12),ap(0,3,5))
	await capture("library-entry-approach-v117-accepted-steps",ap(-2,13,4),ap(0,0,6.3))
	await capture("library-entry-approach-v117-accepted-lower",wp(6,1.8,13),wp(11,1.9,8))
	await capture("library-entry-approach-v117-accepted-soffit",ap(0,7,1.3),ap(0,2.5,2.8))
	var route:Array=[]
	for z in [38.0,30.0,20.0,11.0,9.2,5.2,1.2,-2.0,-4.0]:route.append([ap(0,z),"main approach ascent "+str(z)])
	for p in [[1210,650],[1300,590],[1420,610],[1300,590],[1210,650]]:route.append([map2(p[0],p[1]),"2F exhibition connection "+str(p)])
	for z in [-4.0,-2.0,1.2,5.2,9.2,11.0,20.0,30.0,38.0,39.5]:route.append([ap(0,z,0 if z==39.5 else -100),"main approach descent "+str(z)])
	await fixture(ap(0,40,.3),route)
	var lower:Array=[]
	for p in [Vector3(-12,0,21),Vector3(-12,0,18),Vector3(-12,0,13),Vector3(-12,0,10),Vector3(-12,0,12),Vector3(0,0,12),Vector3(0,0,8),Vector3(6,0,10),Vector3(8,0,12),Vector3(6,0,10),Vector3(0,0,8),Vector3(0,0,12),Vector3(-12,0,12),Vector3(-12,0,10),Vector3(-12,0,18),Vector3(-12,0,21)]:lower.append([wp(p.x,p.y,p.z),"G public door and below-entry aisle "+str(p)])
	await fixture(wp(-12,.3,29),lower)
	var checks:Array=[]
	for item in [[ap(0,5.2,4.3),ap(0,5.2,3.65),false,"old flat roof no longer crosses main stair"],[ap(0,5.2,3.7),ap(0,5.2,2.9),true,"main stair surface"],[ap(0,7,1.4),ap(0,7,2.65),true,"closed116 inclined soffit"],[wp(11,2.4,24),wp(11,1.9,24),false,"old wrongly directed stair removed"],[ep(0,1,6),ep(0,-1,6),false,"registered2F doorway open"]]:
		var q=PhysicsRayQueryParameters3D.create(item[0],item[1]);q.exclude=[world.player.get_rid()];var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=(not hit.is_empty())==item[2]
		checks.append({"case":item[3],"valid":valid});if not valid:failures.append(item[3])
	var report={"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":2,"scope":"new mall rise/main stair/2F threshold and G public aisle;closed116 interior height and real absolute grades remain fitted"}
	FileAccess.open("res://tests/artifacts/library_entry_approach_v117_accepted_run.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_ENTRY_APPROACH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
