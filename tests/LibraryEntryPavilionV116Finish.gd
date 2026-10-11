extends "res://tests/LibraryEntryPavilionV116Final.gd"
func map3(x:float,z:float,y:float=8.8)->Vector3:
	var p:=Lower.point3(x,z,y);return wp(p.x,p.y,p.z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-entry-pavilion-v116-finish-overview",wp(38,15,65),wp(21,7,7))
	await capture("library-entry-pavilion-v116-finish-exhibition",map2(1310,510,6.2),map2(1590,610,6.1))
	await capture("library-entry-pavilion-v116-finish-third",map3(1500,690,10.6),map3(1650,700,10.5))
	await capture("library-entry-pavilion-v116-finish-ground",wp(36,1.8,5),wp(45,1.8,6))
	var route:Array=[]
	for p in [[1500,700],[1600,700],[1680,640],[1600,700],[1500,700],[1450,700]]:route.append([map3(p[0],p[1]),"3F common pavilion return "+str(p)])
	await fixture(map3(1450,700,9.1),route)
	var ground:Array=[]
	for p in [Vector3(39,0,7),Vector3(43,0,5),Vector3(44,0,3),Vector3(43,0,5),Vector3(39,0,7),Vector3(35,0,3)]:ground.append([wp(p.x,p.y,p.z),"G end floor and common glazing "+str(p)])
	await fixture(wp(35,.3,3),ground)
	var checks:Array=[]
	for item in [[map3(1540,765,4.65),map3(1540,765,4.2),true,"2F infill reaches shared brick return"],[wp(43,1.8,7),wp(43,1.8,15),true,"common G glazed end closed"],[map3(1540,765,9.05),map3(1540,765,8.6),true,"3F perimeter floor retained"]]:
		var q=PhysicsRayQueryParameters3D.create(item[0],item[1]);q.exclude=[world.player.get_rid()];var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=(not hit.is_empty())==item[2]
		checks.append({"case":item[3],"valid":valid});if not valid:failures.append(item[3])
	var report={"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":2,"scope":"Final common perimeter changes:3F and G end plus2F infill; earlier2F route unchanged by outward brick adjustment"}
	FileAccess.open("res://tests/artifacts/library_entry_pavilion_v116_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_ENTRY_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
