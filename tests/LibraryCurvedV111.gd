extends "res://tests/LibraryUpperPlanV110.gd"
const Curved=preload("res://world/visual_campus/LibraryCurvedCirculation.gd")
func curve_point(t:float,y:float)->Vector3:
	var p=Curved.at(t,y+Curved.elevation(t));return wp(p.x,p.y,p.z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false)
	var route:Array=[]
	for y in [12.8,16.8]:
		route.append([pp(625,710,y),"curved lower bridge "+str(y)])
		for t in [0.0,.15,.30,.42,.50,.58,.75,.90,1.0]:route.append([curve_point(t,y),"curved flight "+str(y)+" t="+str(t)])
		route.append([pp(840,825,y+4),"curved upper landing "+str(y+4)])
		if y==12.8:
			for p in [[870,825],[865,715],[840,660],[625,660]]:route.append([pp(p[0],p[1],16.8),"5F return outside curved void "+str(p)])
	for p in [[870,825],[840,795],[797,754],[760,722],[725,696],[680,680],[625,674],[625,710],[625,674],[680,680],[725,696],[760,722],[797,754],[840,795],[870,825]]:route.append([pp(p[0],p[1],20.8),"6F bent bridge "+str(p)])
	for p in [Vector3(6.5,20.8,3.4),Vector3(3,20.8,3.4),Vector3(3,20.8,-6.2),Vector3(-3,20.8,-6.2),Vector3(-3,18.8,2),Vector3(-5.7,18.8,2),Vector3(-5.7,16.8,-6.2),Vector3(3,16.8,-6.2)]:route.append([cp(p.x,p.y,p.z),"6F curved landing tocore5F "+str(p)])
	await fixture(pp(625,660,13.1),route)
	if not failures.is_empty():
		var player=world.player;var target=route[legs.size()-1][0];var q=PhysicsRayQueryParameters3D.create(player.global_position+Vector3.UP*.9,target+Vector3.UP*.9);q.exclude=[player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q)
		if not hit.is_empty():print("OBSTRUCTION ",hit.collider.get_path()," ",hit.position)
	var checks:Array=[]
	for sample in [[715,780,16.8,false,"right atrium remains open"],[695,723,14.8,false,"no premature slab across mid flight"],[680,680,20.8,true,"bent6F bridge floor"],[730,680,20.8,false,"former straight6F bridge removed outside bent edge"]]:
		var q=PhysicsRayQueryParameters3D.create(pp(sample[0],sample[1],sample[2]+.15),pp(sample[0],sample[1],sample[2]-.15));q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var ok:bool=(not hit.is_empty())==sample[3];checks.append({"case":sample[4],"valid":ok});if not ok:failures.append(sample[4])
	var report={"version":world.data.version,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":1,"scope":"Newcurvedpublic4F-6Fstairs,bent6Fbridgeandcoreconnection;fittedgeometrynotwholecampusacceptance"}
	FileAccess.open("res://tests/artifacts/library_curved_v111.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_CURVED ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
