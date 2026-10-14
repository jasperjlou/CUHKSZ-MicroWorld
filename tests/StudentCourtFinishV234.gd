extends "res://tests/StudentWestLandingV233.gd"
func shot(label:String)->void:
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/student-court-v234-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	root.disable_3d=true
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(15)
	product.world.player.set_physics_process(false);product.world.player.hide();product.world.ui.hide();root.disable_3d=false
	var eye:=Camera3D.new();product.world.add_child(eye);eye.current=true;eye.fov=68
	for v:Array in [["court",pp(180,310,6.1),pp(400,420,5.3)],["west-stair",pp(185,390,6.1),pp(340,525,9.2)],["paving",pp(320,360,5.9),pp(350,400,4.4)],["drain",pp(592,430,10.5),pp(558,430,8.8)],["front-well",pp(360,330,6.1),pp(240,269,3.2)]]:
		eye.position=v[1];eye.look_at(v[2]);await frames(12);await shot(v[0])
	FileAccess.open("res://tests/artifacts/student_court_v234.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"captures":captures,"scope":"Outdoor floor finish clipped to existing cut slabs; tread material/nosing and fitted drain strip visual only; reuse V233 physics, no new route claims"},"\t"))
	print("STUDENT_COURT_V234 captures=",captures.size());quit()
