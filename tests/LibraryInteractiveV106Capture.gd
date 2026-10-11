extends "res://tests/LibraryStudyPodsV101Capture.gd"
const Room=preload("res://world/visual_campus/LibraryInteractive119.gd")
func rw(p:Vector3)->Vector3:
	var q=Room.point(p);return wp(q.x,q.y,q.z)
func bw(p:Vector3,cell:int)->Vector3:
	var q=(Vector3(43.75,0,3.3) if cell==0 else Vector3(41.05,0,6.0))+Basis(Vector3.UP,-PI*.75)*p
	return wp(q.x,q.y,q.z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-interactive-v106-room",rw(Vector3(3.5,1.8,4.0)),rw(Vector3(-.4,1.8,-4.6)))
	await capture("library-interactive-v106-glass",wp(30,1.8,-6.5),rw(Vector3(0,1.8,1)))
	await capture("library-interactive-v106-tip",wp(34,1.8,-.2),wp(44,1.8,3.8))
	await capture("library-interactive-v106-return",wp(42,1.8,.5),wp(26,1.8,-4))
	var route:Array=[[wp(12,0,-12),"rear cross aisle retained"]]
	for p in [Vector3(-6,0,-3.3),Vector3(-3.4,0,-3.3),Vector3(-3.15,0,-1.8),Vector3(-3.15,0,3.8),Vector3(0,0,3.8),Vector3(2.9,0,3.8),Vector3(2.9,0,6.4)]:route.append([rw(p),"119 two-door circuit "+str(p)])
	for p in [Vector3(30,0,-9),Vector3(35,0,-7),Vector3(39,0,-3),Vector3(42,0,.5)]:route.append([wp(p.x,p.y,p.z),"tapered study aisle "+str(p)])
	for cell in 2:
		for z in [1.9,.35,1.9]:route.append([bw(Vector3(0,0,z),cell),"S10"+str(cell+1)+" door "+str(z)])
	for p in [Vector3(38,0,2.5),Vector3(32,0,1.5),Vector3(30,0,1.5),Vector3(30,0,-6),Vector3(30,0,-9)]:route.append([wp(p.x,p.y,p.z),"117118 public bypass "+str(p)])
	for p in [Vector3(2.9,0,6.4),Vector3(2.9,0,3.8),Vector3(-3.15,0,3.8),Vector3(-3.15,0,-1.8),Vector3(-3.4,0,-3.3),Vector3(-6,0,-3.3)]:route.append([rw(p),"119 return "+str(p)])
	route.append([wp(12,0,-12),"return to registered central rear"])
	await fixture(wp(12,.3,-6),route)
	var checks:Array=[]
	for s in [[wp(45,1.5,1),wp(49,1.5,1),true,"right tip glass enclosure"],[wp(44,.5,0),wp(44,-.2,0),true,"projecting right floor"],[wp(37,1.5,-2),wp(41,1.5,-2),false,"retired upper-shell glass no longer bisects G"],[rw(Vector3(1,1.5,-4.8)),rw(Vector3(1,1.5,-5.7)),true,"119 presentation solid wall"],[rw(Vector3(0,1.5,5.0)),rw(Vector3(0,1.5,5.7)),true,"119 internal glass collider"],[rw(Vector3(2.9,2,4.7)),rw(Vector3(2.9,2,6)),false,"119 second doorway clear"]]:
		var q=PhysicsRayQueryParameters3D.create(s[0],s[1]);q.exclude=[world.player.get_rid()]
		var h=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=(not h.is_empty())==s[2]
		checks.append({"case":s[3],"valid":valid})
		if not valid:failures.append(s[3])
	var report={"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"119 two entrances/seminar aisle,right tapered public wing,two silence cells;upper-floor correspondence not certified"}
	FileAccess.open("res://tests/artifacts/library_interactive_v106.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_INTERACTIVE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
