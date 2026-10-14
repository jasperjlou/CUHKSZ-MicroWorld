extends "res://tests/StageCameraV218.gd"
func lp(x:float,z:float)->Vector3:return lib(Vector3(x,0,z))
func shot(label:String)->void:
	if root.disable_3d:return
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/stage-player-v246-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	root.disable_3d=true
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(15)
	var p:CharacterBody3D=product.world.player
	for mode:bool in [false,true]:
		p.first_person=mode;var label:String="first" if mode else "third"
		await fixture(lp(-18,3.1),[lp(-28.13,3.1),lp(-28.13,1.5),lp(-28.13,3.1),lp(-35,3.1),lp(-35,-3),lp(-35,-7),lp(-20.4,-7),lp(-14.7,-7),lp(-14.7,-9.8),lp(-14.7,-7),lp(-20.4,-7)],label+"-study")
		await fixture(ground(131,-322),[ground(137,-322),ground(137,-312),ground(137,-322),ground(132,-330)],label+"-rear-drain")
		await fixture(ground(96,-499),[ground(106,-499),ground(118,-499),ground(118,-503.5),ground(107,-503.5),ground(96,-503.5),ground(96,-499)],label+"-shaw-side")
	check("camera volumes clear",overlap_frames==0);check("body-to-camera segments clear",blocked_frames==0)
	root.disable_3d=false
	for v:Array in [["study",lp(-28.13,3.1),lp(-29,1.5),false],["shaw",ground(106,-499),Vector3(106,5,-506),true]]:
		p.position=v[1]+Vector3.UP*.12;p.velocity=Vector3.ZERO;p.first_person=v[3];p.orbit_pitch=0;p.orbit_zoom=1
		var direction:Vector3=v[2]-v[1];p.orbit_yaw=atan2(-direction.x,-direction.z)
		await frames(25);await shot(v[0])
	FileAccess.open("res://tests/artifacts/stage_player_v246.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"physical_legs":legs,"checks":checks,"failures":errors,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"per_fixture":per_fixture,"captures":captures,"scope":"V241-V245 library-study,rear drain and Shaw side approach in first/third person plus stationary yaw/pitch;not full-campus"},"\t"))
	print("STAGE_PLAYER_V246 legs=",legs.size()," samples=",samples," errors=",errors);quit(0 if errors.is_empty() else 1)
