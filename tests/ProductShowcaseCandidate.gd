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
	var path := "res://tests/artifacts/product-candidate-"+label+".png"
	root.get_texture().get_image().save_png(path)
	captures.append(path)

func key(code: int) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await frames(2)

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
	var report := {"model_version":product.world.data.version,"product_version":ProjectSettings.get_setting("application/config/version"),"checks":checks,"physical_legs":product.director.results,"failures":errors,"captures":captures,"chapter_count":product.director.chapters.size(),"fast_holds_only":true,"scope":"candidate menu, inputs, physical chapter routes;not a full-campus or final-release acceptance"}
	FileAccess.open("res://tests/artifacts/product_showcase_candidate.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("PRODUCT_RESULT legs=",product.director.results.size()," failures=",errors)
	quit(0 if errors.is_empty() else 1)
