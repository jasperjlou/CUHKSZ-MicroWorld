extends SceneTree
var product: Node
var errors: Array[String] = []
var checks: Array[Dictionary] = []
var captures: Array[String] = []

func _initialize() -> void: run.call_deferred()

func frames(count: int) -> void:
	for _i in range(count): await physics_frame

func check(label: String, valid: bool) -> void:
	checks.append({"label":label,"valid":valid})
	if not valid: errors.append(label)
	print("PRODUCT_CHECK ",label," ",valid)

func shot(label: String) -> void:
	if DisplayServer.get_name()=="headless":return
	await process_frame
	await RenderingServer.frame_post_draw
	var path := "res://tests/artifacts/product-experience-finish-v185-"+label+".png"
	root.get_texture().get_image().save_png(path)
	captures.append(path)

func key(code: int) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await frames(2)
	event.pressed=false;Input.parse_input_event(event);await frames(1)

func run() -> void:
	product = load("res://world/product/CampusProduct.tscn").instantiate()
	root.add_child(product)
	await frames(15)
	check("main scene uses current campus",product.world.data.version==JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/campus_visual_build.json")).version)
	check("two public entries",product.human_button.get_parent().get_children().filter(func(n:Node)->bool:return n is Button).size()==2)
	await shot("menu")
	product.human_button.pressed.emit()
	await frames(20)
	check("player uses same world and physics",product.mode=="player" and product.world.player.is_physics_processing() and not product.world.player.agent_controlled)
	await player_controls()
	await key(KEY_F1)
	check("F1 information visible",product.world.information.visible)
	await key(KEY_F2)
	check("F2 overview pauses player",product.world.top_down and not product.world.player.is_physics_processing())
	await key(KEY_F2)
	check("F2 returns player",not product.world.top_down and product.world.player.is_physics_processing())
	await shot("player")
	await key(KEY_ESCAPE)
	check("player Esc returns two-entry menu",product.mode=="menu" and product.menu.visible)
	product.agent_button.pressed.emit()
	await frames(60)
	await key(KEY_SPACE)
	var pause_position: Vector3 = product.world.player.position
	await frames(20)
	check("showcase pause holds player",product.director.paused and product.world.player.position.distance_to(pause_position)<.001)
	await key(KEY_SPACE)
	check("showcase resumes",not product.director.paused)
	# Faster chapter holds only; the actual 5.1 m/s body and collision steps are unchanged.
	product.director.presentation_speed=12
	var captured: Dictionary={}
	var previous_index := -1
	var count := 0
	while product.director.phase!="complete" and count<60000:
		await physics_frame
		count+=1
		var d: Node = product.director
		if d.index!=previous_index:
			previous_index=d.index
			print("PRODUCT_CHAPTER ",d.index," ",d.chapters[d.index].id)
		if d.phase=="walk" and not captured.has(d.index):
			captured[d.index]=true
			await shot(d.chapters[d.index].id+"-walk")
		if d.phase=="failed":
			errors.append(d.failures.back())
			print("PRODUCT_BLOCKED ",d.index," leg=",d.leg," position=",product.world.player.position," target=",d.chapters[d.index].route[d.leg])
			await shot(d.chapters[d.index].id+"-blocked")
			# Audit the remaining independent chapter fixtures, without claiming seamless playback.
			if d.index+1<d.chapters.size():d.begin_chapter(d.index+1)
			else:break
	check("showcase reached its end",product.director.phase=="complete")
	await key(KEY_ESCAPE)
	check("showcase Esc returns menu",product.mode=="menu" and product.menu.visible)
	product.start_player()
	await frames(20)
	check("player control restored after showcase",not product.world.player.agent_controlled and product.world.player.camera.current and product.world.ui.visible and product.world.player.is_physics_processing())
	var report := {"model_version":product.world.data.version,"product_version":ProjectSettings.get_setting("application/config/version"),"checks":checks,"physical_legs":product.director.results,"failures":errors,"captures":captures,"chapter_count":product.director.chapters.size(),"fast_holds_only":true,"scope":"current-model menu/input/physical playback audit; chapter cuts remain explicit;cross-zone free walking and exported binary separate"}
	FileAccess.open("res://tests/artifacts/product_experience_finish_v185.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("PRODUCT_RESULT legs=",product.director.results.size()," failures=",errors)
	quit(0 if errors.is_empty() else 1)

func player_controls()->void:
	var w:Node3D=product.world;var p:CharacterBody3D=w.player
	check("speed multiplier remains2.5",p.human_speed_multiplier==2.5)
	check("minimap upper left",w.minimap.position==Vector2(18,18) and w.minimap.is_visible_in_tree())
	var press:=InputEventMouseButton.new();press.button_index=MOUSE_BUTTON_RIGHT;press.pressed=true
	Input.parse_input_event(press);await frames(2)
	var motion:=InputEventMouseMotion.new();motion.relative=Vector2(150,-35)
	Input.parse_input_event(motion);await frames(30)
	check("right drag rotates camera",absf(p.orbit_yaw)>.8 and absf(p.orbit_pitch)>.1)
	press.pressed=false;Input.parse_input_event(press);await frames(2)
	var yaw:float=p.orbit_yaw;Input.parse_input_event(motion);await frames(2)
	check("release stops camera drag",is_equal_approx(p.orbit_yaw,yaw))
	var forward:Vector3=-p.camera.global_basis.z;forward.y=0;forward=forward.normalized()
	Input.action_press("move_forward");await frames(20)
	var velocity:Vector3=p.velocity;velocity.y=0
	check("W follows camera",velocity.normalized().dot(forward)>.95)
	check("walk actual12.75mps",absf(velocity.length()-12.75)<.3)
	Input.action_press("jog");await frames(25)
	check("run actual20.75mps",absf(Vector2(p.velocity.x,p.velocity.z).length()-20.75)<.3)
	Input.action_release("jog");Input.action_release("move_forward");await frames(5)
	var wheel:=InputEventMouseButton.new();wheel.button_index=MOUSE_BUTTON_WHEEL_UP;wheel.pressed=true
	Input.parse_input_event(wheel);await frames(2)
	check("wheel zoom",p.orbit_zoom<1)
	await key(KEY_R);await frames(5)
	check("reset clears camera orbit",p.orbit_yaw==0 and p.orbit_pitch==0 and p.orbit_zoom==1 and not w.dragging)
	var physical:=InputEventKey.new();physical.physical_keycode=KEY_F1;physical.pressed=true
	Input.parse_input_event(physical);await frames(2)
	check("physical F1 opens info",w.information.visible)
	physical.echo=true;Input.parse_input_event(physical);await frames(2)
	check("F1 repeat ignored",w.information.visible)
	physical.pressed=false;physical.echo=false;Input.parse_input_event(physical)
	await key(KEY_F1)
	press.pressed=true;Input.parse_input_event(press);await frames(2)
	await key(KEY_F2);await key(KEY_F2)
	Input.parse_input_event(motion);await frames(2)
	check("overview clears held drag",p.orbit_yaw==0 and not w.dragging)
	press.pressed=false;Input.parse_input_event(press)
	var before:Vector3=p.position
	var pick:=InputEventMouseButton.new();pick.button_index=MOUSE_BUTTON_LEFT;pick.pressed=true
	var landmark:Dictionary={}
	for r:Dictionary in w.data.landmarks:
		if r.id=="library_entry":landmark=r;break
	pick.position=w.minimap.project(w.builder.point(landmark.position))
	if DisplayServer.get_name()=="headless":w.minimap._gui_input(pick)
	else:pick.position+=w.minimap.global_position;Input.parse_input_event(pick)
	await frames(2)
	check("map selects library without teleport",w.destination.get("id","")=="library_entry" and p.position.distance_to(before)<.1)
	pick.pressed=false;Input.parse_input_event(pick)
	p.orbit_yaw=1.1;p.orbit_pitch=.3;p.orbit_zoom=.6
	await key(KEY_ESCAPE);product.start_player();await frames(10)
	check("menu reentry resets camera",p.orbit_yaw==0 and p.orbit_pitch==0 and p.orbit_zoom==1 and not w.dragging)
