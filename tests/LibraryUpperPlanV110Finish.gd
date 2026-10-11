extends "res://tests/LibraryUpperPlanV110.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false)
	var route:Array=[]
	for y in [12.8,16.8]:
		for p in [[330,843,y],[470,843,y],[470,825,y],[470,710,y+2],[625,710,y+4],[625,670,y+4]]:route.append([pp(p[0],p[1],p[2]),"upper stair continuation "+str(p)])
		if y==12.8:
			for p in [[625,615,y+4],[330,615,y+4],[330,843,y+4]]:route.append([pp(p[0],p[1],p[2]),"next floor approach "+str(p)])
	for p in [[810,674,20.8],[865,715,20.8],[920,775,20.8]]:route.append([pp(p[0],p[1],p[2]),"6F bridge to right wing "+str(p)])
	await fixture(pp(330,820,13.1),route)
	var wing:Array=[]
	for p in [[300,615],[250,615],[250,455],[320,455],[320,405],[350,405],[350,155],[350,405],[550,405],[550,470],[750,550],[850,625],[900,770],[1030,820],[1000,930],[900,1030],[875,1030]]:wing.append([pp(p[0],p[1],12.8),"left and front wing continuation "+str(p)])
	await fixture(pp(440,615,13.1),wing)
	var racks:Array=[]
	for p in [[800,575],[890,535],[950,490],[1010,470],[1135,340],[1135,250],[1135,340],[1010,470],[950,490],[890,535],[800,575]]:racks.append([pp(p[0],p[1],12.8),"P-Z corrected shelf orientation "+str(p)])
	await fixture(pp(700,615,13.1),racks)
	var report={"version":world.data.version,"physical_legs":legs,"failures":failures,"fixtures":3,"scope":"Unfinished public4F-6F stair circuit,left/front wings and changedP-Zracks;retain unaffectedpriorlegs/corechecks"}
	FileAccess.open("res://tests/artifacts/library_upper_plan_v110_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_UPPER_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
