extends "res://tests/StudentSkylightV231.gd"
func shot(label:String)->void:
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/student-skylight-v232-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	root.disable_3d=true
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(15)
	product.world.player.set_physics_process(false);product.world.player.hide();product.world.ui.hide()
	root.disable_3d=false
	var eye:=Camera3D.new();product.world.add_child(eye);eye.current=true;eye.fov=68
	for v:Array in [["hall",sp(750,660,10.5),sp(560,545,15)],["upward",sp(670,630,10.5),sp(655,568,17.5)],["gallery",sp(480,630,14.1),sp(670,570,16.2)],["detail",sp(690,625,14.5),sp(650,570,16.1)]]:
		eye.position=v[1];eye.look_at(v[2]);await frames(12);await shot(v[0])
	FileAccess.open("res://tests/artifacts/student_skylight_v232.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"captures":captures,"scope":"Visual deep blades, glazing joints and curb only; V231 collision and shaft unchanged; no new physical route result; upper depth remains unregistered"},"\t"))
	print("STUDENT_SKYLIGHT_V232 captures=",captures.size());quit()
