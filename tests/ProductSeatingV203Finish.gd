extends "res://tests/ProductExperienceV185.gd"
func shot(label:String)->void:
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/product-seating-v203-finish-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(40)
	product.start_showcase();var d:Node=product.director
	var chosen:Array[Dictionary]=[]
	for c:Dictionary in d.chapters:
		if c.id=="library-seating":chosen.append(c)
	check("one seating chapter",chosen.size()==1)
	d.chapters=chosen;d.begin_chapter(0);d.presentation_speed=2
	var seen:Dictionary={};var count:=0
	while d.phase!="complete" and d.phase!="failed" and count<5500:
		await physics_frame;count+=1
		var label:=""
		if d.phase=="intro" and d.elapsed>1:label="intro"
		if d.phase=="walk" and d.leg_elapsed>.3 and d.leg in [2,7]:label="leg"+str(d.leg)
		if d.phase=="outro" and d.elapsed>.4:label="upper-arrival"
		if not label.is_empty() and not seen.has(label):seen[label]=true;await shot(label)
	check("physical chapter completes without recovery",d.phase=="complete" and d.failures.is_empty())
	check("architectural showcase keeps avatar hidden",not product.world.player.model.visible)
	if d.phase=="failed":await shot("failed")
	await key(KEY_ESCAPE);product.start_player();await frames(12)
	check("return to player restores third-person avatar",product.world.player.model.visible and not product.world.player.agent_controlled)
	FileAccess.open("res://tests/artifacts/product_seating_v203_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"model_version":product.world.data.version,"checks":checks,"failures":errors+d.failures,"physical_legs":d.results,"captures":captures,"scope":"New seating chapter only; full18-chapter playback and packaging remain pending."},"\t"))
	print("PRODUCT_SEATING_V203_DONE ",errors+d.failures);quit(0 if errors.is_empty() and d.failures.is_empty() else 1)
