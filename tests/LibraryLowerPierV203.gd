extends "res://tests/PlayerViewsV191.gd"
func cp(x:float,y:float,z:float)->Vector3:return lib(Ground.point(Vector3(x,y,z)))
func view(label:String,eye:Vector3,target:Vector3)->void:
	var w=product.world
	w.ui.hide();w.player.hide();w.player.set_physics_process(false)
	w.overview.current=true;w.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;w.overview.fov=58;w.overview.global_position=eye;w.overview.look_at(target)
	await frames(12);await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/library-lower-pier-v203-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(40)
	product.start_player();await frames(12)
	await view("seating-pier",cp(10.2,1.75,-5),cp(5,2.1,2.7))
	await view("wood-stair",cp(-.2,1.8,-2.5),cp(0,3.3,7))
	await view("opening-edge",cp(-3.4,6.2,9),cp(0,3.8,7))
	var p=product.world.player;p.show();p.set_physics_process(true);p.camera.current=true
	var around:Array=[cp(8.2,0,-3.4),cp(8.2,0,-.9),cp(5.8,0,-.9),cp(5.8,0,-3.4)]
	for mode in [false,true]:
		p.first_person=mode
		await fixture(cp(5.8,0,-3.4),around,"pier-"+("first" if mode else "third"))
		for yaw in [0.0,PI/2,PI,-PI/2]:
			p.orbit_yaw=yaw
			for i in 12:await physics_frame;audit_camera()
		await fixture(gp(-1),[gp(6),gp(11.1),gp(6),gp(-1)],"stair-"+("first" if mode else "third"))
	var hit=product.world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(cp(5,1,-2),cp(9,1,-2),1))
	check("observed round pier has solid collision",not hit.is_empty() and str(hit.collider.get_path()).contains("LibraryGroundObservedRoundPier"))
	check("sampled camera volume clear",overlap_frames==0)
	check("sampled body-to-camera segments clear",blocked_frames==0)
	FileAccess.open("res://tests/artifacts/library_lower_pier_v203.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"checks":checks,"failures":errors,"legs":legs,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"captures":captures,"scope":"Two view modes around one fitted column and on retained G stair;three visual views. Does not establish full column grid or whole-campus acceptance."},"\t"))
	print("LIBRARY_LOWER_PIER_V203_DONE ",errors," samples=",samples);quit(0 if errors.is_empty() else 1)
