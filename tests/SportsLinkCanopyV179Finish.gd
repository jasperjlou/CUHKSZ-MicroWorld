extends "res://tests/SportsLinkCanopyV179.gd"
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(cp179(-19,1.5,-.65),cp179(19,1.5,-.65),false,"inner aisle follows retained Hall plinth edge",checks)
	probe(cp179(14,1.5,-1.8),cp179(18,1.5,-1.8),true,"retained plinth not removed for route",checks)
	probe(cp179(5,.5,9.5),cp179(5,-.15,9.5),true,"new court replaces grass with supported paving",checks)
	var route:Array=[]
	for u:float in [19,11,1,-9,-19,-21]:route.append([cp179(u,.108,-.65),"inner aisle clear of retained plinth "+str(u)])
	route.append_array([[cp179(-21,.09,7),"Hall court corner"],[cp179(-10,.09,9.5),"outer hard court Hall end"],[cp179(5,.09,9.5),"former default grass strip"],[cp179(20,.09,9.5),"outer hard court Complex end"],[cp179(21,.108,1.8),"court returns to covered link"]])
	await fixture(cp179(21,.45,-.65),route)
	root.disable_3d=false;await frames(15)
	await capture("canopy-v179-final-overall",cp179(-26,6,8),cp179(1,2.8,0))
	await capture("canopy-v179-final-ground",cp179(-15,1.7,2.2),cp179(-2,.4,.5))
	await capture("canopy-v179-court",cp179(-22,6,17),cp179(8,1,6))
	FileAccess.open("res://tests/artifacts/sports_link_canopy_v179_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Continue inner return clear of existing Hall plinth; newly paved outer court. Initial ten successful legs retained; failed straight line retired."},"\t"))
	print("CANOPY_V179_FINISH ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
