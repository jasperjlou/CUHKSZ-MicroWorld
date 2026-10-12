extends "res://tests/ProductExperienceV185.gd"

func shot(label:String)->void:
	await process_frame
	await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/product-library-v189-"+label+".png"
	root.get_texture().get_image().save_png(path)
	captures.append(path)

func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate()
	root.add_child(product);await frames(15)
	check("two public entries",product.human_button.get_parent().get_children().filter(func(n:Node)->bool:return n is Button).size()==2)
	product.start_player();await frames(15)
	await player_controls()
	await key(KEY_ESCAPE)
	check("Esc returns menu",product.mode=="menu" and product.menu.visible)
	product.start_showcase()
	var d:Node=product.director
	var selected:Array[Dictionary]=[]
	for c:Dictionary in d.chapters:
		if c.id in ["library-pool","library-gallery","library-lower","library-study"]:selected.append(c)
	check("four library chapters present",selected.size()==4)
	d.chapters=selected;d.begin_chapter(0);d.presentation_speed=4
	var photographed:Dictionary={};var count:=0
	while d.phase!="complete" and d.phase!="failed" and count<15000:
		await physics_frame;count+=1
		var id:String=d.chapters[d.index].id
		var label:=""
		if d.phase=="intro" and d.elapsed>1.1:label=id+"-intro"
		if d.phase=="walk" and d.leg_elapsed>.3:
			if id=="library-gallery" and d.leg in [3,6,9,16]:label=id+"-leg"+str(d.leg)
			elif id=="library-pool" and d.leg==7:label=id+"-stone"
			elif id=="library-lower" and d.leg==3:label=id+"-threshold"
		if d.phase=="outro" and id=="library-gallery" and d.elapsed>.35:label=id+"-arrival"
		if not label.is_empty() and not photographed.has(label):
			photographed[label]=true;await shot(label)
	check("four chapters complete without recovery",d.phase=="complete" and d.failures.is_empty())
	if d.phase=="failed":
		print("LIBRARY_SHOWCASE_BLOCKED ",d.index," ",d.leg," ",product.world.player.position," ",d.chapters[d.index].route[d.leg])
		await shot("blocked")
	await key(KEY_ESCAPE)
	check("Agent Esc returns menu",product.mode=="menu")
	product.start_player();await frames(10)
	check("player restored after Agent",not product.world.player.agent_controlled and product.world.player.camera.current)
	var report={"model_version":product.world.data.version,"checks":checks,"physical_legs":d.results,"failures":errors+d.failures,"captures":captures,"scope":"Rendered player input plus four affected library chapters, real physical playback; only chapter transitions cut. Not full campus or packaged binary acceptance."}
	FileAccess.open("res://tests/artifacts/product_library_v189.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("PRODUCT_LIBRARY_V189 ",JSON.stringify(report))
	quit(0 if errors.is_empty() and d.failures.is_empty() else 1)
