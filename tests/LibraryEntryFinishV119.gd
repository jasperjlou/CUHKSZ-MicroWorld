extends "res://tests/LibraryEntryApproachV117.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-entry-v119-overview",Vector3(-1,33,-226),Vector3(65,8,-290))
	await capture("library-entry-v119-portal",wp(57,8,23),map2(1610,650,7))
	await capture("library-entry-v119-carpet",wp(-20.4,1.8,3.6),wp(-20.4,.8,-12))
	await capture("library-entry-v119-lower",wp(-10,1.8,-6),wp(5,1.3,-10))
	var lawn=preload("res://world/visual_campus/LibraryEntryLawn.gd");var route:Array=[]
	for z in [35.0,27.0,19.0,12.0,19.0,27.0,35.0]:
		var p:Vector3=Approach.point(lawn.outer(z)+1.0,z,.135);route.append([wp(p.x,p.y,p.z),"portal clearance along lawn "+str(z)])
	var start:Vector3=Approach.point(lawn.outer(37)+1.0,37,.435);await fixture(wp(start.x,start.y,start.z),route)
	var inside:Array=[]
	for p in [[1520,640],[1610,700],[1680,595],[1610,700],[1520,640],[1420,610]]:inside.append([map2(p[0],p[1]),"inside thickened portal "+str(p)])
	await fixture(map2(1420,610,4.7),inside)
	var report={"version":world.data.version,"physical_legs":legs,"captures":captures,"failures":failures,"fixtures":2,"scope":"new white portal collision along exterior lawn and2F interior;G carpet/mesh ceiling visual-only,fullGexterior access not claimed"}
	FileAccess.open("res://tests/artifacts/library_entry_v119.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_ENTRY_V119 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
