extends "res://tests/TeachingAArcadeV97Capture.gd"

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var n:Node3D=world.builder.buildings.teaching_a.get_node("TeachingACad")
	var route:Array=[]
	for a:Array in [
		[Vector3(-3.7,0,60),"court west corridor"],
		[Vector3(-3.7,0,50),"sunken stair entrance"],[Vector3(-1,0,50),"sunken stair top"],
		[Vector3(6,-2.575,50),"transverse stair descent"],[Vector3(7.5,-2.575,50),"mid landing turn"],
		[Vector3(7.5,-5.15,39),"lower court descent"],[Vector3(7.5,-5.15,38.4),"lower stair toe"],[Vector3(1,-5.15,38.4),"lower court walk"],
		[Vector3(7.5,-5.15,38.4),"lower court return"],[Vector3(7.5,-2.575,50),"lower flight ascent"],
		[Vector3(6,-2.575,50),"mid landing return"],[Vector3(-1,0,50),"upper flight ascent"],
		[Vector3(-3.7,0,50),"west corridor return"],[Vector3(-3.7,0,73.5),"front cross passage"],
		[Vector3(26.8,0,73.5),"lobby return"],[Vector3(28,0,78),"lobby stair toe"],
		[Vector3(28,2.1,87),"lobby first flight"],[Vector3(32,2.1,87),"lobby mid landing"],
		[Vector3(32,4.2,77.5),"second floor arrival"],[Vector3(20,4.2,77.5),"second floor lobby ring"],
		[Vector3(32,4.2,77.5),"upper landing return"],[Vector3(32,2.1,87),"second flight descent"],
		[Vector3(28,2.1,87),"mid landing transfer"],[Vector3(28,0,78),"lobby ground return"]]:route.append([n.to_global(a[0]),a[1]])
	await fixture(n.to_global(Vector3(6,.15,60)),route)
	var report:Dictionary={"version":world.data.version,"failures":failures,"captures":captures,"physical_legs":legs,"scope":"TA CAD ground courts, lower court and public lobby stairs;historical plans and fitted global registration"}
	FileAccess.open("res://tests/artifacts/teaching_a_arcade_existing_v97.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TEACHING_A_CAD_V96 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
