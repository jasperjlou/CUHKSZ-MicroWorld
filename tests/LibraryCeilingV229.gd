extends "res://tests/LibraryServicesFinishV228.gd"
func shot(label:String)->void:
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/library-ceiling-v229-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	root.disable_3d=true
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(15)
	product.world.player.set_physics_process(false);product.world.player.hide();product.world.ui.hide()
	root.disable_3d=false
	var eye:=Camera3D.new();product.world.add_child(eye);eye.current=true;eye.fov=68
	for v:Array in [["stairs-foot",stair(3.3,-4)+Vector3.UP*1.8,stair(3.3,Entry.RUN*.65)+Vector3.UP*.7],["stairs-top",stair(3.3,Entry.RUN+1.5)+Vector3.UP*1.7,stair(3.3,2)],["service-front",svc(3.8,5.0,1.65),svc(.8,.1,1.4)],["ceiling-edge",stair(-2.8,1)+Vector3.UP*1.8,lib(Entry.horizontal(Vector3(0,3.9,Entry.RUN*.55)))]]:
		eye.position=v[1];eye.look_at(v[2]);await frames(12);await shot(v[0])
	FileAccess.open("res://tests/artifacts/library_ceiling_v229.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"captures":captures,"scope":"visual ceiling and slab fascia only; no collision change; reuse V228 physical evidence, no new route assertion"},"\t"))
	print("LIBRARY_CEILING_V229 captures=",captures.size());quit()
