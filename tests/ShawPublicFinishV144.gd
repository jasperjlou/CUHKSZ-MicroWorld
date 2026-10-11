extends "res://tests/ShawWestPlanV143.gd"
func run()->void:
	var product:Node=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(15)
	world=product.world;world.ui.hide();product.menu.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	building=world.builder.buildings.shaw_west.get_node("WestPlanFrameV143")
	for y:float in [4.4,8.8]:
		probe("middle wall replaces guard "+str(y),wp(-18,y+1,7),wp(-18,y+1,9),true)
		probe("forward left wall replaces guard "+str(y),wp(5,y+1,18),wp(3,y+1,18),true)
		probe("forward right wall replaces guard "+str(y),wp(14,y+1,18),wp(16,y+1,18),true)
		probe("forward end wall replaces guard "+str(y),wp(9,y+1,29),wp(9,y+1,31),true)
		probe("stair landing still open "+str(y),wp(3,y+1,26),wp(7,y+1,26),false)
	for pair:Array in [[Vector3(-4,10,-20),Vector3(-6,10,-20)],[Vector3(8,10,-20),Vector3(11,10,-20)],[Vector3(2.8,10,-29),Vector3(2.8,10,-31)]]:probe("hall glass replaces guard "+str(pair[0]),building.to_global(pair[0]),building.to_global(pair[1]),true)
	await capture("shaw-public-v144-window-layers-final",wp(-14,7,23),wp(-18,8,7))
	await capture("shaw-public-v144-hall-final",wp(2.8,10.4,-10),wp(-3,10.4,-24))
	await capture("shaw-public-v144-mid-room-final",wp(-18,10.4,0),wp(-10,10.4,8))
	await capture("shaw-public-v144-stair-final",wp(-7,9,33),wp(7,6,21))
	await capture("shaw-public-v144-roof-side-final",Vector3(177,19,-679),Vector3(154,14.34,-665))
	world.ui.show();await capture("shaw-public-v144-map-final",wp(45,75,52),wp(-10,10,-2));world.ui.hide()
	# Explicit visual-only fixture at the already walked endpoint, not another route pass.
	product.start_showcase();var d:Node=product.director
	for i in d.chapters.size():
		if d.chapters[i].id=="shaw-west":d.begin_chapter(i);break
	while d.phase!="intro":await physics_frame
	world.player.position=d.chapters[d.index].route.back();world.player.set_physics_process(false)
	d.leg=d.chapters[d.index].route.size()-1;d.phase="outro";d.elapsed=0;d.presentation_speed=.1;d.fade.color.a=0;d.camera_snap=true
	await frames(75);await RenderingServer.frame_post_draw
	var end_path:="res://tests/artifacts/product-candidate-shaw-west-v144-end-final.png"
	root.get_texture().get_image().save_png(end_path);captures.append(end_path)
	FileAccess.open("res://tests/artifacts/shaw_public_v144_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"checks":checks,"captures":captures,"failures":failures,"scope":"13boundaryprobes and final images after redundant enclosed deck guards removed; unchanged route/slab/window collisions retain earlier movement records. Endpoint is visual-only fixture."},"\t"))
	quit(0 if failures.is_empty() else 1)
