extends "res://npc/BaseNPC.gd"
const DETECTION_RANGE := 12.0
const FOV_DOT := 0.35
const SECOND_COOLDOWN := 8.0
const REACTION_DELAY := 0.7
var facing := Vector3(0, 0, 1)
var last_warning_time := -100.0
var closed_since_warning := false
var last_perception := false
var reaction_remaining := 0.0
var pending_warning := 0
var acknowledge_remaining := 0.0

func _init() -> void:
	display_name = "老师"
	actor_id = "teacher_01"
	outfit = Color("687e9b")

func _ready() -> void:
	super._ready()
	EventBus.event_emitted.connect(_on_event)

func should_face_player() -> bool:
	return false

func _process(delta: float) -> void:
	super._process(delta)
	if GameState.can_move() and attention_remaining <= 0:
		model.rotation.y = lerp_angle(model.rotation.y, atan2(facing.x, facing.z), minf(delta * 3, 1))

func can_see_player() -> bool:
	if not is_instance_valid(player):
		return false
	var offset := player.global_position - global_position
	offset.y = 0
	if offset.length() > DETECTION_RANGE:
		return false
	var look := Vector3(sin(model.rotation.y), 0, cos(model.rotation.y))
	if offset.length() > 0.1 and look.dot(offset.normalized()) < FOV_DOT:
		return false
	var query := PhysicsRayQueryParameters3D.create(global_position + Vector3(0, 2.475, 0), player.global_position + Vector3(0, 1.575, 0), 3)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or hit.get("collider") == player

func _physics_process(delta: float) -> void:
	if not GameState.can_move():
		return
	if acknowledge_remaining > 0:
		acknowledge_remaining -= delta
		if acknowledge_remaining <= 0 and nearby(DETECTION_RANGE) and not GameState.get_flag("phone_open"):
			say("嗯，这样安全一点。")
			EventBus.emit_event("TEACHER_ACKNOWLEDGED", actor_id)
	if pending_warning > 0:
		reaction_remaining -= delta
		if not GameState.get_flag("phone_open") or not can_see_player():
			pending_warning = 0
			reaction_remaining = 0
		elif reaction_remaining <= 0:
			var second := pending_warning == 2
			pending_warning = 0
			say("怎么又看上了？" if second else "走路注意看路，先把手机收一下。")
			GameState.set_flag("teacher_warned_twice" if second else "teacher_warned", true)
			last_warning_time = GameState.get_value("elapsed")
			EventBus.emit_event("TEACHER_SECOND_WARNING" if second else "TEACHER_WARNED_PLAYER", actor_id)
		return
	var observes: bool = player.moving and GameState.get_flag("phone_open") and can_see_player()
	if observes and not last_perception:
		EventBus.emit_event("TEACHER_SAW_PHONE", actor_id, {"distance":snappedf(global_position.distance_to(player.global_position), 0.01), "line_of_sight":true, "moving":true})
	last_perception = observes
	if not observes:
		return
	if not GameState.get_flag("teacher_warned"):
		pending_warning = 1
	elif closed_since_warning and not GameState.get_flag("teacher_warned_twice") and float(GameState.get_value("elapsed")) - last_warning_time >= SECOND_COOLDOWN:
		pending_warning = 2
	if pending_warning > 0:
		reaction_remaining = REACTION_DELAY
		notice(true)
		EventBus.emit_event("TEACHER_NOTICED_PLAYER", actor_id, {"warning":pending_warning})

func _on_event(record: Dictionary) -> void:
	if record["event"] == "PHONE_CLOSED" and GameState.get_flag("teacher_warned"):
		if not closed_since_warning and can_see_player():
			notice()
			acknowledge_remaining = 0.45
		closed_since_warning = true

func interact() -> void:
	dialogue_requested.emit(display_name, "去参加高桌晚宴吧？沿着连廊往前走，亮着灯的地方就是。", [{"text":"谢谢老师", "action":func(): pass}])
