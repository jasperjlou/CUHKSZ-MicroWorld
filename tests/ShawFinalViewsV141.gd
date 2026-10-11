extends "res://tests/ProductShowcaseCandidate.gd"
## Camera-only review; physical route retained from shaw_showcase_finish_v141.json.
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(15)
	product.start_showcase()
	var d:Node=product.director
	var chapter_index:int=-1
	for i in d.chapters.size():
		if d.chapters[i].id=="shaw-podium":chapter_index=i
	check("Shaw chapter exists",chapter_index>=0)
	d.begin_chapter(chapter_index)
	while d.phase!="intro":await physics_frame
	await frames(80);await shot("shaw-podium-intro-v141-final")
	product.world.player.position=d.chapters[chapter_index].route[-1]+Vector3.UP*.3
	product.world.player.velocity=Vector3.ZERO
	await frames(20)
	d.phase="outro";d.elapsed=0;d.leg=d.chapters[chapter_index].route.size()
	d.presentation_speed=.05;d.camera_snap=true
	await frames(50);await shot("shaw-podium-court-end-v141-final")
	FileAccess.open("res://tests/artifacts/shaw_final_views_v141.json",FileAccess.WRITE).store_string(JSON.stringify({"model_version":product.world.data.version,"captures":captures,"checks":checks,"failures":errors,"scope":"camera-only fixture for intro and court-facing outro; no new physical route claim"},"\t"))
	quit(0 if errors.is_empty() else 1)
