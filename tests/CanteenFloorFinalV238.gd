extends "res://tests/CanteenIslandV236.gd"
func shot(label:String)->void:
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/canteen-floor-v238-final-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();product.world.player.set_physics_process(false);product.world.player.hide();product.world.ui.hide()
	var eye:=Camera3D.new();product.world.add_child(eye);eye.current=true;eye.fov=68
	for v:Array in [["floor-near",pp(395,410,1.6),pp(375,390,.09)],["floor-aisle",pp(650,570,1.7),pp(650,395,.09)],["entry",pp(275,440,1.75),pp(218,438,.3)]]:
		eye.position=v[1];eye.look_at(v[2]);await frames(12);await shot(v[0])
	FileAccess.open("res://tests/artifacts/canteen_floor_v238_final.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"captures":captures,"scope":"Registered noncolliding canteen floor and existing threshold finishes; visual-only; unchanged physical evidence retained"},"\t"))
	print("CANTEEN_FLOOR_FINAL_V238 captures=",captures.size());quit()
