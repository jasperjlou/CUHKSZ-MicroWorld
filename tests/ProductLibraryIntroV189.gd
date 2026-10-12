extends "res://tests/ProductLibraryV189.gd"
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate()
	root.add_child(product);await frames(15);product.start_showcase()
	var d:Node=product.director
	d.set_physics_process(false);product.world.player.set_physics_process(false)
	d.phase="intro";d.fade.color.a=0
	for c:Dictionary in d.chapters:
		if c.id!="library-lower":continue
		d.title.text=c.title;d.detail.text=c.detail
		d.camera.position=c.eye_end;d.camera.look_at(c.look)
		await frames(8);await shot("lower-intro-finish")
	FileAccess.open("res://tests/artifacts/product_library_intro_v189.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"scope":"Lower entry intro camera moved inside G aisle to avoid new ramp fascia; no geometry or physics changes."},"\t"))
	quit()
