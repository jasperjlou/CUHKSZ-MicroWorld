extends "res://tests/LibraryLowerRearV150.gd"
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(dp(0,1.8,-1),dp(0,1.8,1),false,"rear door remains open",checks)
	probe(dp(-5,2,-1),dp(-5,2,1),true,"ground window or pier stays closed",checks)
	probe(dp(-5,4.3,-1),dp(-5,4.3,1),true,"ground wall head closes to slab",checks)
	probe(dp(-5,8.7,-1),dp(-5,8.7,1),true,"second wall head closes to slab",checks)
	for z:float in [-3.35,-1.45]:probe(dp(8,.9,z-.3),dp(8,.9,z+.3),true,"side ramp rail "+str(z),checks)
	probe(dp(-2.9,1.1,-2),dp(-2.1,1.1,-2),true,"porch outer rail",checks)
	probe(dp(2.5,1.1,-3.7),dp(2.5,1.1,-2.9),true,"porch front rail beside stair",checks)
	probe(dp(12.4,1,-2.4),dp(11.6,1,-2.4),false,"ramp toe remains open",checks)
	var route:Array=[]
	for v in [[0,0,-5.6],[0,.48,-3.0],[0,.48,-.5],[0,.48,1.8],[0,.106,4.8],[0,.106,10],[0,.106,14],[0,.106,10],[0,.106,4.8],[0,.48,1.8],[0,.48,-2.4],[3.8,.48,-2.4],[8,.24,-2.4],[12.4,0,-2.4],[14,0,-2.4],[12.4,0,-2.4],[8,.24,-2.4],[3.8,.48,-2.4],[0,.48,-2.4],[0,0,-5.6],[0,0,-7.8]]:route.append([dp(v[0],v[1],v[2]),"rear entry loop "+str(v)])
	await fixture(dp(0,.4,-7.8),route)
	root.disable_3d=false;await frames(15)
	await capture("library-rear-v180-overall",wp(-53,13,-60),wp(-21,5,-30))
	await capture("library-rear-v180-porch",dp(-8,3.2,-10),dp(3,1.5,-1))
	await capture("library-rear-v180-ramp",dp(13.5,1.5,-5.4),dp(3,1.2,-1.8))
	await capture("library-rear-v180-windows",dp(-9,2.4,-7),dp(6,2,0))
	FileAccess.open("res://tests/artifacts/library_rear_access_v180.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Retained fitted rear portal/vestibule and newly guarded ramp; grade and identity not independently registered."},"\t"))
	print("LIBRARY_REAR_V180 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
