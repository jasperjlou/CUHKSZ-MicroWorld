extends "res://tests/LibraryLowerRearV150.gd"
func p2(u:float,v:float,y:float=4.4)->Vector3:
	var q:=LowerP.point2(u,v,y);return wp(q.x,q.y,q.z)
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var route:Array=[]
	for q in [[435,445],[435,408],[405,390],[405,300],[355,300],[355,390],[435,385],[435,408],[435,445],[500.5,445],[500.5,408],[500.5,384],[500.5,408],[500.5,445],[573.5,445],[573.5,408],[573.5,384],[573.5,408],[573.5,445],[644.5,445],[644.5,408],[644.5,384],[644.5,408],[644.5,445],[713.5,445],[713.5,408],[713.5,384],[713.5,408],[713.5,445],[780,445],[780,470],[420,470],[310,470],[300,430],[300,300],[300,430],[310,470]]:
		route.append([p2(q[0],q[1]),"2F rooms/corridor "+str(q)])
	await fixture(p2(420,445,4.7),route)
	var checks:Array=[]
	for u in [435,500.5,573.5,644.5,713.5]:probe(p2(u,440,6),p2(u,400,6),false,"room doorway "+str(u),checks)
	probe(p2(500,385,6),p2(500,345,6),true,"staff office boundary",checks)
	probe(p2(395,280,6),p2(395,225,6),true,"209 rear boundary",checks)
	probe(p2(523,390,6),p2(548,390,6),true,"210211 fitted divider",checks)
	root.disable_3d=false;await frames(12)
	await capture("library-second-v226-final-row",p2(740,483,6.2),p2(470,418,6.1))
	await capture("library-second-v226-final-training",p2(360,290,6.15),p2(437,421,5.8))
	await capture("library-second-v226-final-group",p2(573.5,382,6),p2(573.5,440,5.8))
	await capture("library-second-v226-final-west-aisle",p2(300,310,6.1),p2(300,460,6.1))
	FileAccess.open("res://tests/artifacts/library_second_rooms_v226_final.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"scope":"five2F room envelopes, sharedfrontcorridor and westcore approach; fitted interior divisions; staff vestibule untouched"},"\t"))
	print("LIBRARY_SECOND_ROOMS_V226 legs=",legs.size()," failures=",failures);quit(0 if failures.is_empty() else 1)
