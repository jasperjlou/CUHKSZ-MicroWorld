extends "res://tests/CanteenIslandV236.gd"
func shot(label:String)->void:
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/canteen-finish-v237-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();product.world.player.set_physics_process(false);product.world.player.hide();product.world.ui.hide()
	var eye:=Camera3D.new();product.world.add_child(eye);eye.current=true;eye.fov=68
	for v:Array in [["windows",pp(390,370,1.75),pp(218,430,2.)],["pendants",pp(410,450,1.8),pp(350,330,2.65)],["service",pp(645,450,1.8),pp(700,350,3.1)],["entry",pp(275,440,1.75),pp(218,438,1.85)],["overview",pp(420,560,1.8),pp(350,380,2.6)]]:
		eye.position=v[1];eye.look_at(v[2]);await frames(12);await shot(v[0])
	FileAccess.open("res://tests/artifacts/canteen_finish_v237.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"captures":captures,"scope":"Noncolliding window linings and lighting/ceiling finishes; no new physics result; V236 retained"},"\t"))
	print("CANTEEN_FINISH_V237 captures=",captures.size());quit()
