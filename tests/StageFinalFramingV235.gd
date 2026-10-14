extends "res://tests/StageViewsV235.gd"
func shot(label:String)->void:
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/stage-final-framing-v235-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_showcase();var d:Node=product.director
	d.set_physics_process(false)
	for i in d.chapters.size():
		var c:Dictionary=d.chapters[i]
		if c.id not in ["library-public-stairs","student-front-west301"]:continue
		d.index=i;d.leg=c.route.size();d.phase="outro";d.camera_snap=true;d.fade.color.a=0
		d.title.text=c.title;d.detail.text=c.detail
		product.world.player.set_physics_process(false);product.world.player.position=c.route.back();product.world.player.velocity=Vector3.ZERO
		for tick in 45:await physics_frame;audit(d.camera)
		await shot(c.id+"-end")
		if c.id=="student-hall301":
			d.phase="walk";d.leg=5;d.camera_snap=true;product.world.player.position=c.route[4]
			for tick in 30:await physics_frame;audit(d.camera)
			await shot("hall301-centre")
	check("final endpoints camera volumes clear",overlap.is_empty())
	FileAccess.open("res://tests/artifacts/stage_final_framing_v235.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":errors,"captures":captures,"camera_samples":sampled,"overlaps":overlap,"scope":"Actual final waypoint outro fixtures and hall centre framing; not extra walking evidence"},"\t"))
	print("STAGE_FINAL_FRAMING_V235 captures=",captures.size()," failures=",errors);quit(0 if errors.is_empty() else 1)
