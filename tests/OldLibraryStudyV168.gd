extends "res://tests/OldLibraryAtriumV167.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for x:float in [-15,-6,3]:probe(ap(x,0,4.9),ap(x,0,15.5),false,"new ceiling details keep void "+str(x),checks)
	probe(ap(16.23,.50,9.5),ap(16.23,.50,9.0),true,"desk tabletop collision",checks)
	probe(ap(21,-4,10.0),ap(21,4,10.0),false,"desk island cross-aisle",checks)
	probe(ap(-1,-3.8,10),ap(-1,3.8,10),false,"central landing entry stays clear",checks)
	var route:Array=[]
	for p in [Vector2(-1,3.8),Vector2(-1,5.2),Vector2(12,5.2),Vector2(21,5.2),Vector2(21,0),Vector2(21,-5.2),Vector2(29,-5.2),Vector2(29,0),Vector2(29,4.16),Vector2(31,4.16),Vector2(29,4.16),Vector2(29,5.2),Vector2(21,5.2),Vector2(12,5.2),Vector2(-1,5.2),Vector2(-1,3.8),Vector2(-1,1.4)]:route.append([ap(p.x,p.y,8.42),"3F study and core access "+str(p)])
	await fixture(ap(-1,1.4,8.7),route)
	await capture("old-library-v168-study",ap(21,4.5,10.1),ap(21,-1,9.6))
	await capture("old-library-v168-desk",ap(19.1,2.6,10.0),ap(17.4,.6,9.2))
	await capture("old-library-v168-ceiling",ap(24,-4.5,10.0),ap(17,1,11.5))
	await capture("old-library-v168-atrium",ap(-18,5.2,10.1),ap(3,0,9))
	await capture("old-library-v168-ground",ap(16,2,1.85),ap(7,0,2.3))
	FileAccess.open("res://tests/artifacts/old_library_study_v168.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"3F fitted study islands and ceiling details;end/central stair runs unchanged;current2026layout not independently established."},"\t"))
	print("OLD_LIBRARY_STUDY_V168 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
