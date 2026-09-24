extends Node3D
signal speech_requested(text: String)
signal dialogue_requested(speaker: String, text: String, options: Array)
const Kit := preload("res://world/MeshKit.gd")
const INTERACTION_RANGE := 3.8
var display_name := "同学"
var actor_id := "npc"
var outfit := Color("5f9a8f")
var model: Node3D
var player: CharacterBody3D
var idle_phase := 0.0
var name_label: Label3D
var bubble: Label3D
var ring: MeshInstance3D
var bubble_remaining := 0.0
var wave_remaining := 0.0
var attention_remaining := 0.0
var interaction_remaining := 0.0
var highlighted := false

func _ready() -> void:
	model = Kit.person(self, outfit)
	name_label = Kit.label(self, display_name, Vector3(0, 3.65, 0), 27)
	bubble = Kit.label(self, "", Vector3(0, 4.55, 0), 24)
	bubble.pixel_size = 0.022
	bubble.width = 460
	bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bubble.no_depth_test = false
	bubble.hide()
	var geometry := TorusMesh.new()
	geometry.inner_radius = 0.95
	geometry.outer_radius = 1.03
	geometry.rings = 20
	ring = Kit.mesh(self, geometry, Vector3(0, 0.035, 0), Color("e6c783"))
	ring.hide()

func _process(delta: float) -> void:
	if GameState.get_flag("paused") or GameState.get_flag("modal_open") or GameState.get_flag("game_finished"):
		return
	idle_phase += delta
	model.position.y = sin(idle_phase * 1.8) * 0.025
	attention_remaining = maxf(0, attention_remaining - delta)
	wave_remaining = maxf(0, wave_remaining - delta)
	if attention_remaining > 0 or should_face_player():
		face_point(player.global_position, delta)
	var arm: Node3D = model.get_node("RightArm")
	arm.rotation.z = lerpf(arm.rotation.z, -2.15 + sin(idle_phase * 9) * 0.28 if wave_remaining > 0 else 0.0, minf(delta * 10, 1))
	name_label.visible = nearby(18) and not player.photo_mode
	name_label.text = display_name + (" · [E] 交谈" if highlighted else "")
	ring.visible = highlighted or attention_remaining > 0
	ring.scale = Vector3.ONE * (1.0 + sin(idle_phase * 3) * 0.035)
	if bubble_remaining > 0:
		bubble_remaining -= delta
		bubble.visible = bubble_remaining > 0 and nearby(20) and not player.photo_mode
	if interaction_remaining > 0:
		interaction_remaining -= delta
		if interaction_remaining <= 0:
			GameState.set_flag("busy", false)
			interact()

func should_face_player() -> bool:
	return nearby(7) and GameState.get_flag("started")

func face_point(point: Vector3, delta: float) -> void:
	var offset := point - global_position
	if Vector2(offset.x, offset.z).length() > 0.05:
		model.rotation.y = lerp_angle(model.rotation.y, atan2(offset.x, offset.z), minf(delta * 7, 1))

func notice(wave: bool = false) -> void:
	attention_remaining = 3.5
	if wave:
		wave_remaining = 1.8

func say(words: String) -> void:
	bubble.text = words
	bubble_remaining = clampf(2.0 + words.length() * 0.10, 3.5, 6.0)
	bubble.show()
	speech_requested.emit(display_name + "：" + words)

func begin_interaction() -> void:
	if not GameState.can_move() or not nearby(INTERACTION_RANGE):
		return
	notice()
	GameState.set_flag("busy", true)
	interaction_remaining = 0.3
	EventBus.emit_event("INTERACTION_STARTED", actor_id)

func nearby(radius: float = INTERACTION_RANGE) -> bool:
	return is_instance_valid(player) and global_position.distance_to(player.global_position) < radius

func interact() -> void:
	pass
