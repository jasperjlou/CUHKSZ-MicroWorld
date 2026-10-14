extends "res://tests/LibraryHallFloorV230.gd"
func shot(label:String)->void:
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/library-hall-floor-v230-finish-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	root.disable_3d=true
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(15)
	product.world.player.set_physics_process(false);product.world.player.hide();product.world.ui.hide();root.disable_3d=false
	var eye:=Camera3D.new();product.world.add_child(eye);eye.current=true;eye.fov=68
	for v:Array in [["return-front",door(-5.9,2.2,6.05),door(-5.9,0,5.9)],["return-context",door(-2.7,4.0,6.2),door(-4.0,0,5.9)],["hall-floor",plan(1000,760,7.6),plan(920,720,4.41)]]:
		eye.position=v[1];eye.look_at(v[2]);await frames(12);await shot(v[0])
	FileAccess.open("res://tests/artifacts/library_hall_floor_v230_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"captures":captures,"scope":"decorative mullion and rounded return face;12 initial physical legs retained, not rerun"},"\t"))
	print("LIBRARY_HALL_FLOOR_V230_FINISH captures=",captures.size());quit()
