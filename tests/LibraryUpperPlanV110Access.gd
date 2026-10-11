extends "res://tests/LibraryUpperPlanV110.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false)
	var wing:Array=[]
	for p in [[313,615],[313,455],[320,405],[350,405],[350,155],[350,405],[550,405],[550,470],[750,550],[850,625],[900,770],[1030,820],[1000,930],[900,1030],[875,1030]]:wing.append([pp(p[0],p[1],12.8),"clear left/front aisles "+str(p)])
	await fixture(pp(300,615,13.1),wing)
	var upper:Array=[]
	for p in [[865,715],[900,690],[1040,690],[1110,820],[1100,930],[990,1030],[960,1020]]:upper.append([pp(p[0],p[1],20.8),"6F around research room groups "+str(p)])
	for p in [Vector3(6.5,20.8,1),Vector3(3,20.8,1),Vector3(3,20.8,-6.2),Vector3(-3,20.8,-6.2),Vector3(-3,18.8,2),Vector3(-5.7,18.8,2),Vector3(-5.7,16.8,-6.2),Vector3(3,16.8,-6.2)]:upper.append([cp(p.x,p.y,p.z),"6F registered wing to core and5F "+str(p)])
	await fixture(pp(810,674,21.1),upper)
	var fab:Array=[]
	var centre:=Plan.point(930,402,12.8);var basis:=Basis(Vector3.UP,PI/4-.056)
	for z in [4.2,1.5,4.2]:
		var p:Vector3=centre+basis*Vector3(0,0,z);fab.append([wp(p.x,p.y,p.z),"401 public doorway "+str(z)])
	var start:Vector3=centre+basis*Vector3(0,.3,5.8);await fixture(wp(start.x,start.y,start.z),fab)
	var report={"version":world.data.version,"physical_legs":legs,"failures":failures,"fixtures":3,"scope":"Remainingleft/front4Faisles,6Frightroom-bypass/coreconnection,FabLabdoor;notallroominteriors"}
	FileAccess.open("res://tests/artifacts/library_upper_plan_v110_access.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_UPPER_ACCESS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
