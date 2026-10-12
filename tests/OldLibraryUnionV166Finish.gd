extends "res://tests/OldLibraryUnionV166.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(op(40,-20,4.9),op(44,-20,4.9),true,"outer rear structural sill enclosed",checks)
	for x:float in [-1.,1.]:probe(op(x*20,-13,1.7),op(x*29,-13,1.7),false,"buried side glass clipped "+str(x),checks)
	probe(op(27,-11,1.7),op(27,-8,1.7),false,"buried rear glass removed",checks)
	var route:Array=[]
	for p in [Vector2(27,3),Vector2(18,3),Vector2(0,3),Vector2(0,-7),Vector2(0,-16),Vector2(27,-16),Vector2(27,3),Vector2(18,3)]:route.append([op(p.x,p.y,.12),"retained door alignment "+str(p)])
	await fixture(op(27,-16,.35),route)
	await capture("old-library-v166-door",op(16,3,1.9),op(29,3,1.9))
	await capture("old-library-v166-envelope-final",op(3,21,27),op(24,-12,13))
	FileAccess.open("res://tests/artifacts/old_library_union_v166_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Ground clipped glazing and retained z3 door; unchanged third-core and upper-wing routes reuse first batch."},"\t"))
	print("OLD_LIBRARY_UNION_V166_FINISH ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
