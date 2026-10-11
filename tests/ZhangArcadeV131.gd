extends "res://tests/CardBankRoomV130.gd"
var front:Node3D
func pt(x:float,z:float,y:float=0)->Vector3:return front.to_global(Vector3(x,y,z))
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	front=world.builder.buildings.zhang_lingbin.get_node("RetainedPhotoFrontage")
	if DisplayServer.get_name()!="headless":
		await capture("zhang-arcade-v131-door",pt(2.2,25.0,1.7),pt(3,19.1,1.65))
		await capture("zhang-arcade-v131-service",pt(-2,24.6,1.75),pt(-25,24.6,1.8))
		await capture("zhang-arcade-v131-glass",pt(6.0,24.3,1.72),pt(27,24.1,3.3))
		await capture("zhang-arcade-v131-recess",pt(3,16.6,1.70),pt(3,25.5,1.6))
		FileAccess.open("res://tests/artifacts/zhang_arcade_v131_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	var route:Array=[]
	for pair:Array in [[Vector3(-22,0,24.5),"utility frontage"],[Vector3(-10,0,24.5),"nameplate and plain wall"],[Vector3(3,0,24.5),"double entrance approach"],[Vector3(3,0,20.4),"actual front door threshold"],[Vector3(3,0,17),"dark entry recess"],[Vector3(3,0,15.2),"recess inner aperture"],[Vector3(0,0,15.2),"existing public undercroft"],[Vector3(3,0,15.2),"recess return alignment"],[Vector3(3,0,20.4),"recess return"],[Vector3(3,0,24.5),"front door outward return"],[Vector3(14,0,24.5),"arcade behind exterior stair"],[Vector3(27,0,24.5),"glazed wing end"],[Vector3(30.5,0,24.5),"frontage side corner"],[Vector3(30.5,0,31),"stone apron connection"],[Vector3(12.5,0,31),"outer stair approach"],[Vector3(12.5,0,26.85),"exterior stair foot"],[Vector3(-5,4.925,26.85),"retained stair up"],[Vector3(-5,4.925,23.6),"retained upper gallery"],[Vector3(-5,4.925,26.85),"upper landing return"],[Vector3(12.5,0,26.85),"retained stair down"],[Vector3(12.5,0,31),"outer apron return"],[Vector3(-30.5,0,31),"stone apron toward service end"],[Vector3(-30.5,0,24.5),"service end return"]]:route.append([front.to_global(pair[0]),pair[1]])
	await fixture(pt(-30.5,24.5,.3),route)
	probe("plain service wall is solid",pt(-12,23,1.4),pt(-12,21,1.4),true)
	probe("central door clear",pt(3,23.5,1.6),pt(3,20.5,1.6),false)
	probe("open door leaf has collision",pt(1.3,22.3,1.4),pt(2.0,22.3,1.4),true)
	probe("glazed right frontage is solid",pt(16,23,1.5),pt(16,21,1.5),true)
	probe("entry recess ceiling exists",pt(3,18.5,3),pt(3,18.5,4),true)
	FileAccess.open("res://tests/artifacts/zhang_arcade_v131_physics.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":1,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
