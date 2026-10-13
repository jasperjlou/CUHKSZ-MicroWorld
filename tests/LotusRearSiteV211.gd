extends "res://tests/LibraryLowerRearV150.gd"
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(Vector3(115.7,3.17,-340),Vector3(116.8,3.17,-340),false,"relocated round aperture",checks)
	probe(Vector3(115.7,3.17,-345),Vector3(116.8,3.17,-345),true,"relocated pond screen solid span",checks)
	probe(Vector3(118.5,3.2,-360),Vector3(119.5,3.2,-360),false,"old wall retired from road approach",checks)
	for z:float in [-360,-350,-340]:probe(Vector3(120,3.3,z),Vector3(120,2,z),true,"dry walk support "+str(z),checks)
	var road:Array=[]
	for p in [[130,-350],[125,-366],[116,-382],[116,-400],[116,-382],[125,-366],[130,-350],[135,-322]]:road.append([Vector3(p[0],world.builder.height(p[0],p[1])+.075,p[1]),"adjusted avenue bend "+str(p)])
	await fixture(Vector3(135,world.builder.height(135,-322)+.3,-322),road)
	var walking:Array=[]
	for p in [[122,-332.5],[120,-337],[120,-350],[120,-361],[119,-365.5],[110.5,-368],[110.5,-382],[110.5,-399.238],[102,-399.238],[110.5,-399.238],[110.5,-368],[119,-365.5],[120,-361],[120,-350],[120,-337],[122,-332.5],[124,-328]]:walking.append([Vector3(p[0],world.builder.height(p[0],p[1])+.075,p[1]),"pond dry walk and student entry "+str(p)])
	await fixture(Vector3(124,world.builder.height(124,-328)+.3,-328),walking)
	root.disable_3d=false;await frames(12)
	await capture("pond-rear-v211-road",Vector3(133,8,-344),Vector3(116,3,-372))
	await capture("pond-rear-v211-walk",Vector3(121,4,-361),Vector3(118,3,-340))
	await capture("pond-rear-v211-screen",Vector3(106,4.2,-347),Vector3(117,3.2,-350))
	await capture("pond-rear-v211-grade",Vector3(128,9,-355),Vector3(117,3,-332))
	FileAccess.open("res://tests/artifacts/lotus_rear_site_v211.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"scope":"changed rear avenue, pond-bank screen and graded dry walk;two fixtures;not surveyed geometry"},"\t"))
	print("LOTUS_REAR_SITE_V211 ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
