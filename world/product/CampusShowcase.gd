extends Node
## Chapter cuts are explicit; each chapter uses the real CharacterBody3D without recovery teleports.
signal chapter_started(index: int)
signal finished(success: bool)
const FONT = preload("res://systems/ChineseText.gd").FONT
var world: Node3D
var camera: Camera3D
var ui: CanvasLayer
var fade: ColorRect
var title: Label
var detail: Label
var status: Label
var progress: ProgressBar
var chapters: Array[Dictionary] = []
var index := -1
var leg := 1
var phase := "idle"
var running := false
var paused := false
var elapsed := 0.0
var leg_elapsed := 0.0
var stationary_time := 0.0
var last_progress_position := Vector3.ZERO
var floor_limit := -1000.0
var results: Array[Dictionary] = []
var failures: Array[String] = []
var presentation_speed := 1.0
var camera_snap := true

func _ready() -> void:
	chapters = preload("res://world/product/ShowcaseChapters.gd").build(world)
	camera = Camera3D.new()
	camera.fov = 58
	camera.near = .12
	camera.far = 1700
	world.add_child(camera)
	ui = CanvasLayer.new()
	ui.layer = 10
	add_child(ui)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(root)
	var band := ColorRect.new()
	band.color = Color(.025,.07,.065,.92)
	band.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	band.offset_top = -134
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(band)
	title = text(band, "", Vector2(32,18), 25)
	detail = text(band, "", Vector2(32,57), 16)
	status = text(band, "", Vector2(32,91), 13)
	progress = ProgressBar.new()
	progress.show_percentage = false
	progress.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	progress.offset_bottom = 3
	band.add_child(progress)
	fade = ColorRect.new()
	fade.color = Color(.025,.07,.065,0)
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(fade)
	ui.hide()

func text(parent: Node, value: String, position: Vector2, font_size: int) -> Label:
	var l := Label.new()
	l.text = value
	l.position = position
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", Color("f1eedc"))
	parent.add_child(l)
	return l

func start() -> void:
	stop()
	results.clear()
	failures.clear()
	GameState.reset()
	GameState.set_flag("started",true)
	world.player.agent_controlled = true
	world.player.human_camera_enabled = false
	world.player.show()
	# Keep the physical body walking, but leave close architectural views unobstructed.
	world.player.model.hide()
	ui.show()
	camera.current = true
	running = true
	begin_chapter(0)

func stop() -> void:
	running = false
	paused = false
	phase = "idle"
	if is_instance_valid(world.player):
		world.player.navigation_direction = Vector2.ZERO
		world.player.velocity = Vector3.ZERO
		world.player.set_physics_process(false)
	if is_instance_valid(ui): ui.hide()

func begin_chapter(next_index: int) -> void:
	index = clampi(next_index,0,chapters.size()-1)
	leg = 1
	elapsed = 0
	phase = "cut"
	paused = false
	world.player.set_physics_process(false)
	world.player.navigation_direction = Vector2.ZERO
	world.player.velocity = Vector3.ZERO
	camera_snap = true

func _physics_process(delta: float) -> void:
	if not running or paused: return
	elapsed += delta
	var c: Dictionary = chapters[index]
	var player: CharacterBody3D = world.player
	match phase:
		"cut":
			fade.color.a = clampf(elapsed * presentation_speed / .6, 0, 1)
			if elapsed * presentation_speed >= .6:
				player.position = c.route[0] + Vector3.UP * .3
				player.velocity = Vector3.ZERO
				player.set_physics_process(true)
				title.text = "%02d / %02d   %s" % [index+1,chapters.size(),c.title]
				detail.text = c.detail
				status.text = "Agent · 编排导览    空格 暂停 / 继续    ← → 切换章节    Esc 主菜单"
				phase = "intro"
				elapsed = 0
				chapter_started.emit(index)
		"intro":
			fade.color.a = 1-clampf(elapsed * presentation_speed / .7,0,1)
			var t := clampf(elapsed * presentation_speed / 5.0,0,1)
			camera.position = c.eye.lerp(c.eye_end, smoothstep(0,1,t))
			camera.look_at(c.look)
			if elapsed >= .4 and t >= 1:
				phase = "walk"
				elapsed = 0
				start_leg()
		"walk":
			var target: Vector3 = c.route[leg]
			var difference := Vector2(target.x-player.position.x,target.z-player.position.z)
			leg_elapsed += delta
			stationary_time += delta
			if player.position.distance_to(last_progress_position) > .25:
				last_progress_position = player.position
				stationary_time = 0
			if difference.length() <= .18 and absf(player.position.y-target.y)<.4:
				results.append({"chapter":c.id,"leg":leg,"seconds":leg_elapsed,"target":[target.x,target.y,target.z],"end":[player.position.x,player.position.y,player.position.z],"valid":true})
				leg += 1
				if leg >= c.route.size():
					player.navigation_direction = Vector2.ZERO
					phase = "outro"
					elapsed = 0
				else: start_leg()
			else:
				player.navigation_direction = difference.normalized() if difference.length()>.18 else Vector2.ZERO
				if stationary_time > 8 or leg_elapsed > 90 or player.position.y < floor_limit:
					fail_route("%s / 路段 %d" % [c.title,leg])
		"outro":
			if elapsed * presentation_speed > 2:
				if index+1 < chapters.size(): begin_chapter(index+1)
				else:
					phase = "complete"
					player.set_physics_process(false)
					status.text = "本次展示结束    空格 从东门重播    ← → 回看章节    Esc 主菜单"
					finished.emit(failures.is_empty())
	progress.value = 100.0*(index+float(leg)/maxi(1,c.route.size()))/chapters.size()

func start_leg() -> void:
	leg_elapsed = 0
	stationary_time = 0
	last_progress_position = world.player.position
	floor_limit = minf(world.player.position.y,chapters[index].route[leg].y)-.65

func fail_route(where: String) -> void:
	failures.append(where)
	phase = "failed"
	world.player.navigation_direction = Vector2.ZERO
	world.player.set_physics_process(false)
	status.text = "该段通行受阻，展示已停止："+where+"    ← → 回看其他章节    Esc 主菜单"
	finished.emit(false)

func _process(delta: float) -> void:
	if not running or paused or phase not in ["walk","outro"]: return
	var player: CharacterBody3D = world.player
	var c: Dictionary = chapters[index]
	var anchor := player.position + Vector3.UP*1.25
	var target: Vector3 = c.route[mini(leg,c.route.size()-1)]
	var forward := Vector3(target.x-player.position.x,0,target.z-player.position.z).normalized()
	var desired: Vector3 = player.position + c.offset
	if c.get("heading_camera",false):
		if forward.length_squared()<.1:
			var before:Vector3=c.route[maxi(0,leg-1)];forward=Vector3(target.x-before.x,0,target.z-before.z).normalized()
		desired=player.position-forward*1.6+Vector3.UP*1.8
	var detail_camera:Dictionary=c.get("leg_camera",{}).get(leg,{}) if phase=="walk" else {}
	if not detail_camera.is_empty():desired=detail_camera.eye
	# Share the player's swept sphere so near-plane edges clear new rails/soffits too.
	desired = player.safe_camera_point(anchor,desired)
	var look := anchor + forward*1.6
	if c.get("heading_camera",false):look.y=player.position.y+1.65
	if not detail_camera.is_empty():look=detail_camera.look
	if phase=="outro" and c.has("outro_look"):look=c.outro_look
	camera.position = desired if camera_snap else camera.position.lerp(desired,1-exp(-4*delta))
	# Check the blended position as well, so smoothing cannot cut through a corner.
	camera.position = player.safe_camera_point(anchor,camera.position)
	if camera.position.distance_to(look) > .05:
		var rotation: Quaternion = camera.global_transform.looking_at(look).basis.get_rotation_quaternion()
		camera.quaternion = rotation if camera_snap else camera.quaternion.slerp(rotation,1-exp(-5*delta))
	camera_snap = false

func _unhandled_key_input(event: InputEvent) -> void:
	if not running or not event is InputEventKey or not event.is_pressed() or event.is_echo():return
	match event.keycode:
		KEY_SPACE:
			if phase == "complete":start()
			elif phase != "failed":
				paused = not paused
				world.player.set_physics_process(not paused and phase != "cut")
				status.text = "已暂停    空格 继续    ← → 切换章节    Esc 主菜单" if paused else "Agent · 编排导览    空格 暂停 / 继续    ← → 切换章节    Esc 主菜单"
			get_viewport().set_input_as_handled()
		KEY_LEFT, KEY_RIGHT:
			begin_chapter(index+(-1 if event.keycode==KEY_LEFT else 1))
			get_viewport().set_input_as_handled()
