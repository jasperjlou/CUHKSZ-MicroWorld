extends "res://tests/StageViewsV246.gd"
func shot(label:String)->void:
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/stage-outro-accepted-v246-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_showcase();var d:Node=product.director
	for i in d.chapters.size():
		var c:Dictionary=d.chapters[i]
		if c.id not in IDS:continue
		d.begin_chapter(i)
		while d.phase!="intro":await physics_frame
		await frames(100)
		product.world.player.set_physics_process(false);d.set_physics_process(false)
		var prior:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://tests/artifacts/stage_agent_v246.json"))
		var arrivals:Array=prior.physical_legs.filter(func(r:Dictionary)->bool:return r.chapter==c.id)
		var e:Array=arrivals.back().end
		product.world.player.position=Vector3(e[0],e[1],e[2]);product.world.player.velocity=Vector3.ZERO
		d.leg=c.route.size();d.phase="outro";d.camera_snap=true
		await frames(30);audit(d.camera);await shot(c.id)
		d.set_physics_process(true)
	check("final camera sphere clear",overlap.is_empty())
	FileAccess.open("res://tests/artifacts/stage_outro_accepted_v246.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":errors,"captures":captures,"camera_samples":sampled,"overlaps":overlap,"scope":"Both final outros at recorded physical arrival positions and actual completed leg index;intro fade allowed to clear;rear-Shaw look orientation corrected;not a route rerun"},"\t"))
	print("STAGE_OUTRO_ACCEPTED_V246 captures=",captures.size()," failures=",errors);quit(0 if errors.is_empty() else 1)
