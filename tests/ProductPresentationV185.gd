extends "res://tests/ProductExperienceV185.gd"
var timing:Array=[]
func sample_render(label:String)->void:
	var values:Array[float]=[]
	var last:int=Time.get_ticks_usec()
	for i in 45:
		await process_frame
		var now:int=Time.get_ticks_usec()
		if i>=5:values.append(float(now-last)/1000.)
		last=now
	values.sort()
	timing.append({"view":label,"median_frame_ms":values[values.size()/2],"p95_frame_ms":values[int(values.size()*.95)],"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)})

func run()->void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(15)
	await shot("menu")
	product.start_player();await frames(15)
	await player_controls()
	await shot("player-controls")
	await sample_render("player-gate")
	product.start_showcase()
	var d:Node=product.director
	for i in d.chapters.size():
		d.set_physics_process(true);d.begin_chapter(i)
		while d.phase!="intro":await physics_frame
		await frames(65)
		d.set_physics_process(false);product.world.player.set_physics_process(false)
		await shot(d.chapters[i].id+"-intro")
		# Explicit camera fixture only. All chapter physical legs were audited separately.
		var mid:int=maxi(1,d.chapters[i].route.size()/2)
		product.world.player.position=d.chapters[i].route[mid]+Vector3.UP*.10
		d.leg=mini(mid+1,d.chapters[i].route.size()-1);d.phase="walk";d.camera_snap=true
		await frames(12)
		await shot(d.chapters[i].id+"-middle")
		if d.chapters[i].id in ["library-lower","library-rear-shaw","research"]:await sample_render(d.chapters[i].id)
	product.show_menu()
	FileAccess.open("res://tests/artifacts/product_presentation_v185.json",FileAccess.WRITE).store_string(JSON.stringify({"model_version":product.world.data.version,"captures":captures,"checks":checks,"failures":errors,"timing":timing,"scope":"Rendered controls including real GUI map hit test;intro/mid camera fixtures only,no extra physical route claim;uncapped local GPU timing sample"},"\t"))
	print("PRODUCT_PRESENTATION_V185_DONE ",errors);quit(0 if errors.is_empty() else 1)
