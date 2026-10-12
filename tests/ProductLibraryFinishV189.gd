extends "res://tests/ProductLibraryV189.gd"

func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate()
	root.add_child(product);await frames(15);product.start_showcase()
	var d:Node=product.director
	d.set_physics_process(false);product.world.player.set_physics_process(false)
	for c:Dictionary in d.chapters:
		if c.id!="library-pool":continue
		d.phase="intro";d.fade.color.a=0
		d.camera.position=c.eye_end;d.camera.look_at(c.look)
		await frames(8);await shot("pool-seam-finish")
	for i in d.chapters.size():
		var c:Dictionary=d.chapters[i]
		if c.id!="library-gallery":continue
		d.index=i;d.phase="walk";d.leg=16;d.camera_snap=true
		product.world.player.position=c.route[15]+Vector3.UP*.06
		await frames(10);await shot("gallery-terrace-finish")
	var report={"captures":captures,"scope":"Visual finish only: half-metre dry paving join and 15mm gallery finish; physical surfaces and route unchanged, reuse product_library_v189.json."}
	FileAccess.open("res://tests/artifacts/product_library_finish_v189.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	quit()
