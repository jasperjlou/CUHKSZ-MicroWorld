extends "res://tests/LibraryDiagonalV107Capture.gd"
const Plan=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
const Core=preload("res://world/visual_campus/LibraryServiceCores.gd")
func pp(x:float,z:float,y:float)->Vector3:
	var p=Plan.point(x,z,y);return wp(p.x,p.y,p.z)
func lp(x:float,y:float,z:float)->Vector3:
	var p=Core.local_point(0,Vector3(x,y,z));return wp(p.x,p.y,p.z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var route:Array=[]
	for y in [8.8,12.8,16.8]:
		for p in [[470,825,y],[470,710,y+2],[625,710,y+4],[625,670,y+4]]:route.append([pp(p[0],p[1],p[2]),"registered public stair "+str(p)])
		if y<16.8:
			for p in [[625,615,y+4],[330,615,y+4],[330,820,y+4],[470,820,y+4]]:route.append([pp(p[0],p[1],p[2]),"public stair return approach "+str(p)])
	for p in [[810,674,20.8],[865,715,20.8],[920,775,20.8]]:route.append([pp(p[0],p[1],p[2]),"6F bridge to right wing "+str(p)])
	await fixture(pp(470,840,9.1),route)
	var wing:Array=[]
	for p in [[660,645],[660,615],[700,615],[800,575],[890,535],[950,490],[1010,470],[1135,340],[1135,250],[1135,340],[1010,470],[950,490],[890,535],[800,575],[700,615],[660,615],[660,645],[660,615],[440,615],[440,645],[300,645],[300,620],[250,620],[250,455],[320,455],[320,405],[350,405],[350,155],[350,405],[550,405],[550,470],[750,550],[850,625],[900,770],[1030,820],[1000,930],[900,1030],[875,1030]]:wing.append([pp(p[0],p[1],12.8),"4F registered wings "+str(p)])
	await fixture(pp(660,660,13.1),wing)
	var left:Array=[]
	for i in range(2,4):
		var y:float=Core.LEVELS[i];var top:float=Core.LEVELS[i+1]
		for p in [Vector3(-1.45,y,-3.5),Vector3(-1.45,(y+top)/2,3.8),Vector3(1.45,(y+top)/2,3.8),Vector3(1.45,top,-3.8),Vector3(5,top,-3.8),Vector3(1.45,top,-3.8)]:left.append([lp(p.x,p.y,p.z),"left core narrower footprint "+str(p)])
	await fixture(lp(1.45,9.1,-3.8),left)
	var checks:Array=[]
	for sample in [[540,767,12.8,false,"left irregular void"],[720,786,12.8,false,"right curved void"],[880,1130,12.8,true,"deeper front wing"],[330,100,12.8,true,"rear reading wing"],[400,220,16.8,false,"5F double height rear bay"],[500,500,20.8,false,"6F removed left wing"],[930,402,12.8,true,"FabLab supporting floor"],[800,670,20.8,true,"6F connecting bridge"]]:
		var q=PhysicsRayQueryParameters3D.create(pp(sample[0],sample[1],sample[2]+.25),pp(sample[0],sample[1],sample[2]-.1));q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var ok:bool=(not hit.is_empty())==sample[3]
		checks.append({"case":sample[4],"valid":ok});if not ok:failures.append(sample[4])
	var report={"version":world.data.version,"physical_legs":legs,"checks":checks,"failures":failures,"fixtures":3,"scope":"New public stairs3F-6F,upper4F wing circulation,narrowedleftcore3F-5F,newvoids/slabs;not wholelibrary/campus acceptance"}
	FileAccess.open("res://tests/artifacts/library_upper_plan_v110_final.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_UPPER_PLAN ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
