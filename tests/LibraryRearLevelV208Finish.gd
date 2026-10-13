extends "res://tests/LibraryLowerRearV150.gd"
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(wp(-32.8,2,-25.5),wp(-32.8,2,-26.5),true,"G toilet aisle end enclosed behind all three doors",checks)
	probe(wp(-32.8,2,-18),wp(-32.8,2,-25.2),false,"G toilet public frontage clear",checks)
	var route:Array=[]
	for z:float in [-20,-22.5,-24.3,-22.5,-20,-18]:route.append([wp(-32.8,.1,z),"retained G toilet aisle "+str(z)])
	await fixture(wp(-32.8,.4,-18),route)
	root.disable_3d=false;await frames(12)
	await capture("library-rear-v208-final-porch",dp(-8,7.2,-10),dp(3,5.9,-1))
	await capture("library-rear-v208-final-g-aisle",wp(-31.5,1.8,-17.5),wp(-32.4,1.8,-25))
	FileAccess.open("res://tests/artifacts/library_rear_level_v208_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"scope":"G toilet aisle closure corrected behind all doors; visual slab edge only elsewhere"},"\t"))
	print("LIBRARY_REAR_LEVEL_V208_FINISH ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
