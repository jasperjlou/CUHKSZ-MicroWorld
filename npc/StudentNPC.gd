extends "res://npc/BaseNPC.gd"
signal photo_flash
var clock: Node
var companion: Node3D
var backdrop_sign: Label3D
var photo_remaining := 0.0
var invitation_remaining := 0.0
var shutter_fired := false
const PHOTO_COST := 35.0
const PHOTO_DURATION := 3.2

func _init() -> void:
	display_name = "拍照同学"
	actor_id = "photo_student"
	outfit = Color("d58365")

func _process(delta: float) -> void:
	super._process(delta)
	if GameState.get_flag("paused") or GameState.get_flag("modal_open") or GameState.get_flag("game_finished") or not GameState.get_flag("started"):
		return
	if photo_remaining > 0:
		photo_remaining -= delta
		face_point(player.camera.global_position, delta)
		if is_instance_valid(companion):
			var other: Node3D = companion.get_child(0)
			var offset: Vector3 = player.camera.global_position - companion.global_position
			other.rotation.y = lerp_angle(other.rotation.y, atan2(offset.x, offset.z), minf(delta * 7, 1))
		if photo_remaining <= 0.65 and not shutter_fired:
			shutter_fired = true
			photo_flash.emit()
			EventBus.emit_event("PHOTO_SHUTTER", actor_id)
		if photo_remaining <= 0:
			complete_photo()
	elif invitation_remaining > 0:
		invitation_remaining -= delta
		if invitation_remaining <= 0 and not GameState.get_flag("photo_request_seen"):
			say("同学，可以帮我们拍张照吗？马上要进场了。")
			GameState.set_flag("photo_request_seen", true)
			EventBus.emit_event("PHOTO_REQUESTED", actor_id)
	elif GameState.can_move() and nearby(12.0) and not GameState.get_flag("photo_request_seen"):
		notice(true)
		invitation_remaining = 0.4

func interact() -> void:
	if GameState.get_flag("helped_student"):
		dialogue_requested.emit(display_name, "拍得不错，谢谢啦！快去赴宴吧。", [{"text":"不客气，一会儿见", "action":func(): pass}])
		return
	if not GameState.get_flag("photo_request_seen"):
		GameState.set_flag("photo_request_seen", true)
		EventBus.emit_event("PHOTO_REQUESTED", actor_id)
	dialogue_requested.emit(display_name, "同学，可以帮我们拍张照吗？马上要进场了。

大约会耽误半分钟。", [{"text":"好啊", "action":accept_photo}, {"text":"不好意思，我快迟到了", "action":decline_photo}])

func accept_photo() -> void:
	if GameState.get_flag("helped_student") or photo_remaining > 0 or GameState.get_flag("game_finished"):
		return
	GameState.set_flag("busy", true)
	if GameState.get_flag("phone_open"):
		GameState.set_flag("phone_open", false)
		EventBus.emit_event("PHONE_CLOSED")
	EventBus.emit_event("PHOTO_ACCEPTED", actor_id)
	bubble.text = "谢谢！我们站好啦。"
	bubble_remaining = 2.0
	bubble.show()
	wave_remaining = 0
	photo_remaining = PHOTO_DURATION
	if is_instance_valid(backdrop_sign):
		backdrop_sign.hide()
	shutter_fired = false
	var center := global_position
	if is_instance_valid(companion):
		center = (global_position + companion.global_position) / 2.0
	player.begin_photo(center)

func complete_photo() -> void:
	photo_remaining = 0
	player.end_photo()
	if is_instance_valid(backdrop_sign):
		backdrop_sign.show()
	say("拍得不错，谢谢啦！")
	GameState.set_flag("helped_student", true)
	GameState.set_flag("busy", false)
	EventBus.emit_event("PHOTO_COMPLETED", actor_id)
	clock.advance(PHOTO_COST)

func decline_photo() -> void:
	notice()
	say("没事没事，你先忙。")
	GameState.set_flag("declined_photo", true)
	EventBus.emit_event("PHOTO_DECLINED", actor_id)
