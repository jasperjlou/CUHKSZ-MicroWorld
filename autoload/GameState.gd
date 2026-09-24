extends Node
## Authoritative state; no rendering, file IO, or verification dependencies.
signal changed(key: String, value: Variant)

const START_TIME := 18.0 * 3600.0 + 55.0 * 60.0
const DEADLINE := 19.0 * 3600.0
const END_TIME := 19.0 * 3600.0 + 4.0 * 60.0
var values: Dictionary = {}

func _ready() -> void:
	reset()

func reset() -> void:
	values = {
		"phone_open": false, "friend_message_received": false,
		"responded_to_friend": false, "teacher_warned": false,
		"teacher_warned_twice": false, "photo_request_seen": false,
		"helped_student": false, "declined_photo": false,
		"reached_high_table": false, "arrival_time": -1.0,
		"arrived_on_time": false, "game_finished": false,
		"current_location": "start_plaza", "player_speed_state": "idle",
		"current_game_time": START_TIME, "elapsed": 0.0,
		"started": false, "busy": false, "modal_open": false,
		"paused": false, "current_task": "helpful_student"
	}
	changed.emit("reset", null)

func set_flag(key: String, value: bool) -> void:
	set_value(key, value)

func get_flag(key: String) -> bool:
	return bool(values.get(key, false))

func set_value(key: String, value: Variant) -> void:
	if values.get(key) == value:
		return
	values[key] = value
	changed.emit(key, value)

func get_value(key: String, fallback: Variant = null) -> Variant:
	return values.get(key, fallback)

func snapshot() -> Dictionary:
	return values.duplicate(true)

func can_move() -> bool:
	return get_flag("started") and not (get_flag("game_finished") or get_flag("busy") or get_flag("modal_open") or get_flag("paused"))

static func format_time(seconds: float, with_seconds: bool = false) -> String:
	if seconds < 0:
		return "未到达"
	var total := int(seconds)
	var result := "%02d:%02d" % [total / 3600, (total / 60) % 60]
	if with_seconds:
		result += ":%02d" % (total % 60)
	return result
