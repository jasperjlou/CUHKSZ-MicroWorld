extends "res://tests/PlayerViewsV191.gd"
const Grey218=preload("res://world/visual_campus/LibraryGreyEntryStair.gd")
const Rear218=preload("res://world/visual_campus/LibraryLowerRearEnvelope.gd")
var current_fixture:=""
var per_fixture:Dictionary={}

func rear(x:float,y:float,z:float)->Vector3:return lib(Rear218.door_point(Vector3(x,y,z)))
func ground(x:float,z:float)->Vector3:return Vector3(x,product.world.builder.height(x,z)+.075,z)
func shot(label:String)->void:
	if DisplayServer.get_name()=="headless":return
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/stage-camera-v218-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)

func audit_camera()->void:
	var p:CharacterBody3D=product.world.player;var space:=p.get_world_3d().direct_space_state
	var q:=PhysicsShapeQueryParameters3D.new();var sphere:=SphereShape3D.new();sphere.radius=.20
	q.shape=sphere;q.collision_mask=1;q.exclude=[p.get_rid()];q.transform=Transform3D(Basis.IDENTITY,p.camera.global_position)
	var overlaps:=space.intersect_shape(q,4)
	var ray:=PhysicsRayQueryParameters3D.create(p.position+Vector3.UP*1.5,p.camera.global_position,1,[p.get_rid()])
	var hit:=space.intersect_ray(ray);samples+=1
	if not per_fixture.has(current_fixture):per_fixture[current_fixture]={"samples":0,"overlaps":0,"blocked":0}
	per_fixture[current_fixture].samples+=1
	if not overlaps.is_empty():overlap_frames+=1;per_fixture[current_fixture].overlaps+=1
	if not hit.is_empty():blocked_frames+=1;per_fixture[current_fixture].blocked+=1
	if (not overlaps.is_empty() or not hit.is_empty()) and bad_samples.size()<24:
		var objects:Array=[]
		for entry in overlaps:objects.append(str(entry.collider.get_path()))
		bad_samples.append({"fixture":current_fixture,"player":str(p.position),"eye":str(p.camera.global_position),"overlap_objects":objects,"ray_object":str(hit.collider.get_path()) if not hit.is_empty() else ""})

func fixture(start:Vector3,targets:Array,label:String)->void:
	current_fixture=label;await super.fixture(start,targets,label)
	var p:CharacterBody3D=product.world.player;var yaw:float=p.orbit_yaw
	for turn:float in [0,PI/2,PI,-PI/2]:
		p.orbit_yaw=yaw+turn
		for pitch:float in [-.30,.30]:
			p.orbit_pitch=pitch
			for i in 12:await physics_frame;audit_camera()
	p.orbit_pitch=0

func showcase_views()->void:
	# Still fixtures inspect the authored composition; continuous playback is audited
	# separately by ProductReviewV218 and is never inferred from these placements.
	product.start_showcase();await frames(5)
	var d:Node=product.director;var p:CharacterBody3D=product.world.player
	d.set_physics_process(false);d.fade.color.a=0
	for id:String in ["library-grey-stair","library-rear-shaw","old-gate","research-perimeter","sports-forecourt"]:
		for i in d.chapters.size():
			var c:Dictionary=d.chapters[i]
			if c.id!=id:continue
			d.index=i;d.leg=1;d.phase="intro";d.title.text=c.title;d.detail.text=c.detail
			d.camera.position=c.eye_end;d.camera.look_at(c.look)
			await frames(12);await shot("agent-"+id+"-intro")
			var leg:int=mini(2,c.route.size()-1)
			if id=="research-perimeter":leg=6
			if id=="sports-forecourt":leg=4
			d.leg=leg;d.phase="walk";d.camera_snap=true
			p.position=c.route[leg-1].lerp(c.route[leg],.5)+Vector3.UP*.12;p.velocity=Vector3.ZERO;p.navigation_direction=Vector2.ZERO;p.set_physics_process(true)
			await frames(25);await shot("agent-"+id+"-walk")
			d.leg=c.route.size()-1;d.phase="outro";d.camera_snap=true;p.position=c.route[-1]+Vector3.UP*.12;p.velocity=Vector3.ZERO
			await frames(25);await shot("agent-"+id+"-outro")

func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(15)
	var p:CharacterBody3D=product.world.player
	var grey:Array=[]
	for v:Vector3 in Grey218.points():grey.append(lib(v))
	if DisplayServer.get_name()=="headless":
		for mode:bool in [false,true]:
			p.first_person=mode;var suffix:String="first" if mode else "third"
			var stair:Array=grey.slice(1);var down:Array=grey.duplicate();down.reverse();stair.append_array(down.slice(1))
			await fixture(grey[0],stair,"grey-stair-"+suffix)
			await fixture(rear(0,3.92,-7),[rear(0,3.92,-5.6),rear(0,4.4,-3),rear(0,4.4,-.5),rear(0,4.4,2),rear(0,4.4,-.5),rear(0,4.4,-2.4),rear(3.8,4.4,-2.4),rear(8,4.16,-2.4),rear(12.5,3.92,-2.4)],"rear-portal-"+suffix)
			await fixture(lib(Vector3(-31.5,.1,-17.5)),[lib(Vector3(-31.5,.1,-20)),lib(Vector3(-32.8,.1,-20)),lib(Vector3(-32.8,.1,-24.3)),lib(Vector3(-32.8,.1,-20)),lib(Vector3(-31.5,.1,-20)),lib(Vector3(-31.5,.1,-17.5))],"lower-aisle-"+suffix)
			await fixture(Vector3(56,6.64,-375),[Vector3(56,6.64,-350),Vector3(56,6.64,-331),Vector3(35,6.64,-331),Vector3(13,6.64,-331)],"upper-link-"+suffix)
			await fixture(Vector3(56,2.24,-365),[Vector3(56,2.24,-350),Vector3(56,2.24,-337),Vector3(56,2.24,-350),Vector3(56,2.24,-365)],"lower-link-"+suffix)
			await fixture(ground(124,-328),[ground(122,-332.5),ground(120,-337),ground(120,-345),ground(120,-337),ground(122,-332.5),ground(124,-328)],"lotus-slope-"+suffix)
			await fixture(Vector3(-201,2.24,-790),[Vector3(-181,2.275,-790),Vector3(-168,2.42,-790),Vector3(-181,2.275,-790),Vector3(-181,2.32,-815)],"old-gate-"+suffix)
		check("sampled player camera volume clear",overlap_frames==0)
		check("sampled player-to-eye segments clear",blocked_frames==0)
	else:
		for view:Array in [["grey-foot",grey[0],grey[2],false],["grey-upper",grey[-1],grey[1],false],["rear-portal",rear(0,4.4,-2.4),rear(0,4.4,2),true],["lower-aisle",lib(Vector3(-32.8,.1,-20)),lib(Vector3(-32.8,.1,-24)),true],["upper-link",Vector3(56,6.64,-350),Vector3(56,6.64,-375),false],["lotus-slope",ground(120,-337),ground(124,-328),false]]:
			p.position=view[1]+Vector3.UP*.12;p.velocity=Vector3.ZERO;p.first_person=view[3];p.orbit_pitch=0;p.orbit_zoom=1
			var direction:Vector3=view[2]-view[1];p.orbit_yaw=atan2(-direction.x,-direction.z)
			await frames(25);await shot(view[0])
		await showcase_views()
	var suffix:String="physical" if DisplayServer.get_name()=="headless" else "visual"
	FileAccess.open("res://tests/artifacts/stage_camera_v218_"+suffix+".json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"physical_legs":legs,"checks":checks,"failures":errors,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"per_fixture":per_fixture,"captures":captures,"scope":"V205-V217 changed player camera fixtures in two modes, incl stationary yaw/pitch; not full-campus acceptance"},"\t"))
	print("STAGE_CAMERA_V218 ",suffix," legs=",legs.size()," samples=",samples," overlaps=",overlap_frames," blocked=",blocked_frames," failures=",errors)
	quit(0 if errors.is_empty() else 1)
