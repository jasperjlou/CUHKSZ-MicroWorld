extends "res://tests/StageCameraV218.gd"
const SP=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const SR=preload("res://world/visual_campus/StudentThirdRooms.gd")
func sp(u:float,v:float,y:float=0.075)->Vector3:return SP.world(u,v,y)
func sr(u:float,v:float,y:float=8.8)->Vector3:return SR.world(u,v,y)
func shot(label:String)->void:
	if DisplayServer.get_name()=="headless":return
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/student-stage-camera-v225-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func student_showcase_views()->void:
	product.start_showcase();await frames(5)
	var d:Node=product.director;var p:CharacterBody3D=product.world.player
	d.set_physics_process(false);d.fade.color.a=0
	for id:String in ["student-serenity","student-lotus","student-third-rooms","student-hall301"]:
		for i in d.chapters.size():
			var c:Dictionary=d.chapters[i]
			if c.id!=id:continue
			d.index=i;d.leg=1;d.phase="intro";d.title.text=c.title;d.detail.text=c.detail
			d.camera.position=c.eye_end;d.camera.look_at(c.look)
			await frames(12);await shot("agent-"+id+"-intro")
			var leg:int=5 if id=="student-serenity" else (4 if id=="student-lotus" else (6 if id=="student-third-rooms" else 10))
			d.leg=leg;d.phase="walk";d.camera_snap=true
			p.position=c.route[leg-1].lerp(c.route[leg],.5)+Vector3.UP*.12;p.velocity=Vector3.ZERO;p.navigation_direction=Vector2.ZERO;p.set_physics_process(true)
			await frames(25);await shot("agent-"+id+"-walk")
			if id=="student-hall301":
				d.leg=c.route.size()-1;d.phase="outro";d.camera_snap=true;p.position=c.route[-1]+Vector3.UP*.12;p.velocity=Vector3.ZERO
				await frames(25);await shot("agent-hall301-outro")
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(15)
	var p:CharacterBody3D=product.world.player
	if DisplayServer.get_name()=="headless":
		for mode:bool in [false,true]:
			p.first_person=mode;var suffix:String="first" if mode else "third"
			await fixture(sp(180,438),[sp(240,438),sp(270,438),sp(270,365),sp(400,365),sp(650,365),sp(650,445),sp(750,447.5),sp(650,445),sp(650,365)],"serenity-"+suffix)
			await fixture(sp(400,300,4.4),[sp(450,300,4.4),sp(480,300,4.4),sp(480,315,4.4),sp(525,315,4.4),sp(525,215,4.4),sp(650,215,4.4),sp(650,306,4.4),sp(740,306,4.4),sp(650,306,4.4),sp(650,400,4.4)],"lotus-"+suffix)
			await fixture(sr(469,220),[sr(469,133),sr(442,133),sr(442,78),sr(442,115),sr(484,115),sr(484,78),sr(484,115),sr(564,133),sr(564,220)],"rooms-"+suffix)
			await fixture(sr(720,485),[sr(749,485),sr(749,520),sr(730,550),sr(650,550),sr(500,550),sr(470,610),sr(445,676),sr(405,676),sr(445,676),sr(530,655),sr(720,655)],"hall-"+suffix)
			await fixture(sp(400,440,4.4),[sp(580,440,8.8),sp(650,440,8.8),sp(650,320,8.8),sp(590,320,8.8),sp(585,285,8.8),sp(750,285,12.4),sp(585,285,8.8),sp(590,320,8.8),sp(650,320,8.8)],"court-stairs-"+suffix)
		check("camera volumes clear",overlap_frames==0);check("camera sightlines clear",blocked_frames==0)
	else:
		for view:Array in [["ground",sp(400,365),sp(650,365),false],["lotus",sp(480,315,4.4),sp(570,338,4.4),false],["hall",sr(650,550),sr(500,600),false],["hall-first",sr(530,655),sr(590,530),true],["rooms-first",sr(484,78),sr(484,115),true]]:
			p.position=view[1]+Vector3.UP*.12;p.velocity=Vector3.ZERO;p.first_person=view[3];p.orbit_pitch=0;p.orbit_zoom=1
			var direction:Vector3=view[2]-view[1];p.orbit_yaw=atan2(-direction.x,-direction.z)
			await frames(25);await shot(view[0])
		await student_showcase_views()
	var suffix:String="physical" if DisplayServer.get_name()=="headless" else "visual"
	FileAccess.open("res://tests/artifacts/student_stage_camera_v225_"+suffix+".json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"physical_legs":legs,"checks":checks,"failures":errors,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"per_fixture":per_fixture,"captures":captures,"scope":"V219-V224 student publicinteriors+court stairs,first/thirdperson movement and stationaryyawpitch; physicalgeometry audit,decorative-onlyocclusion reviewed separately"},"\t"))
	print("STUDENT_STAGE_CAMERA_V225 ",suffix," legs=",legs.size()," samples=",samples," overlaps=",overlap_frames," blocked=",blocked_frames," failures=",errors)
	quit(0 if errors.is_empty() else 1)
