extends "res://tests/CanteenIslandV236.gd"
func shot(label:String)->void:
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/canteen-island-v236-finish-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();product.world.player.set_physics_process(false);product.world.player.hide();product.world.ui.hide()
	var eye:=Camera3D.new();product.world.add_child(eye);eye.current=true;eye.fov=68
	for v:Array in [["curve",pp(635,425,1.8),pp(565,430,1.7)],["front",pp(565,493,1.7),pp(565,430,1.65)]]:
		eye.position=v[1];eye.look_at(v[2]);await frames(12);await shot(v[0])
	FileAccess.open("res://tests/artifacts/canteen_island_v236_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"captures":captures,"scope":"Noncolliding tiled upper pier and light trace; revised unobstructed view; physical evidence remains V236"},"\t"))
	print("CANTEEN_ISLAND_V236_FINISH captures=",captures.size());quit()
