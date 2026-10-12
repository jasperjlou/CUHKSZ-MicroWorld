extends "res://tests/StudentRegisteredV153.gd"
func cp179(u:float,y:float,v:float)->Vector3:
	return world.builder.buildings["sports_complex"].get_node("BetweenHallsCanopy").to_global(Vector3(u,y,v))
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for v:float in [-1.8,1.8]:
		probe(cp179(-19,1.5,v),cp179(19,1.5,v),false,"clear longitudinal aisle "+str(v),checks)
		probe(cp179(5,.5,v),cp179(5,-.15,v),true,"continuous stone support "+str(v),checks)
	probe(cp179(0,1.5,-.6),cp179(0,1.5,.6),true,"white column collision",checks)
	probe(cp179(-22.8,1.5,1.8),cp179(-20.8,1.5,1.8),false,"Hall end open",checks)
	probe(cp179(20.8,1.5,1.8),cp179(22.8,1.5,1.8),false,"Complex end open",checks)
	var route:Array=[]
	for u:float in [-19,-11,-1,9,19,21]:route.append([cp179(u,.108,1.8),"Hall to Complex covered aisle "+str(u)])
	route.append_array([[Vector3(21,2.24,-929),"Complex forecourt turn"],[Vector3(21,2.24,-936),"existing service doorway"],[Vector3(21,2.24,-929),"service doorway return"],[cp179(21,.108,-1.8),"opposite covered aisle join"]])
	for u:float in [11,1,-9,-19,-21]:route.append([cp179(u,.108,-1.8),"Complex to Hall covered aisle "+str(u)])
	await fixture(cp179(-22,.45,1.8),route)
	root.disable_3d=false;await frames(15)
	await capture("canopy-v179-overall",cp179(-26,6,8),cp179(1,2.8,0))
	await capture("canopy-v179-frame",cp179(-5,2.2,1.8),cp179(6,3.6,0))
	await capture("canopy-v179-roof",cp179(0,7,8),cp179(0,3.5,0))
	await capture("canopy-v179-ground",cp179(-15,1.7,2.2),cp179(-2,.4,.5))
	FileAccess.open("res://tests/artifacts/sports_link_canopy_v179.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Both rebuilt covered aisles and existing Complex service doorway. Retained fitted alignment, no whole-site registration claim."},"\t"))
	print("CANOPY_V179 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
