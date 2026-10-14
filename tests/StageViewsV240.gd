extends "res://tests/StageViewsV235.gd"
func shot(label:String)->void:
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/stage-views-v240-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_showcase();var d:Node=product.director
	for i in d.chapters.size():
		var c:Dictionary=d.chapters[i]
		if c.id!="student-serenity":continue
		d.begin_chapter(i)
		while d.phase!="intro":await physics_frame
		await frames(100);audit(d.camera);await shot("intro")
		d.set_physics_process(false)
		product.world.player.set_physics_process(false)
		for leg:int in [4,11]:
			product.world.player.position=c.route[leg-1];product.world.player.velocity=Vector3.ZERO;product.world.player.navigation_direction=Vector2.ZERO
			d.phase="walk";d.leg=leg;d.camera_snap=true
			await frames(25);audit(d.camera);await shot("walk-"+str(leg))
		product.world.player.position=c.route[-1];d.phase="outro";d.camera_snap=true
		await frames(30);audit(d.camera);await shot("outro")
	check("composed camera volumes clear",overlap.is_empty())
	FileAccess.open("res://tests/artifacts/stage_views_v240.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"captures":captures,"checks":checks,"failures":errors,"camera_samples":sampled,"overlaps":overlap,"scope":"normal-speed opening plus independent window/counter walk and final camera fixtures;not continuous motion evidence"},"\t"))
	print("STAGE_VIEWS_V240 captures=",captures.size()," errors=",errors);quit(0 if errors.is_empty() else 1)
