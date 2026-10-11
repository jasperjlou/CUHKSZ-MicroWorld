extends "res://tests/ShawPodiumPlanV142.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	building=world.builder.buildings.shaw_east
	if DisplayServer.get_name()!="headless":
		await capture("shaw-plan-v142-left-room-final",wp(-32,2.2,.2),wp(-26,2,-9))
		await capture("shaw-plan-v142-front-room-final",wp(12,2.2,27),wp(22.5,2.0,20.5))
		await capture("shaw-plan-v142-courts-final",wp(-1,24,21),wp(-4,3,-3))
		FileAccess.open("res://tests/artifacts/shaw_ground_v142_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	await fixture(wp(-39,.3,0),[
		[wp(-35.5,.45,0),"side threshold"],[wp(-31,.45,0),"side room entry"],
		[wp(-31,.45,-8),"service enclosure approach"],[wp(-31,.45,-10.5),"service opening"],
		[wp(-31,.45,-14),"back corner cleared of terrain"],[wp(-31,.45,-10.5),"back corner return"],
		[wp(-31,.45,-8),"service enclosure exit"],[wp(-25,.45,-8),"public rear cross aisle"],
		[wp(-25,.45,-14),"other cleared rear corner"],[wp(-25,.45,-8),"public rear return"],
		[wp(-25,.45,0),"side room return"],[wp(-35.5,.45,0),"door return"],[wp(-39,0,0),"side stair exit"]])
	for p:Vector2 in [Vector2(-31,-14),Vector2(-25,-14),Vector2(0,-14),Vector2(23,-14)]:
		level_probe("ground under public rear "+str(p),p.x,p.y,P.F1)
	level_probe("retained second-floor rear entry",6.8,-28,P.F2)
	probe("no terrain rising in public rear room",wp(-31,.8,-14),wp(-31,.8,-10.5),false)
	FileAccess.open("res://tests/artifacts/shaw_ground_v142_physics.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":1,"failures":failures,"scope":"terrain cut below supported public floor, rear-room corners and unchanged rear2F entrance support; initial48 room/stair legs retained"},"\t"))
	quit(0 if failures.is_empty() else 1)
