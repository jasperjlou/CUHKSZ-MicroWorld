extends RefCounted
const Verifier := preload("res://systems/TaskVerifier.gd")
var presets: Array = []

func _init() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://tasks/tasks.json"))
	if parsed is Array:
		presets = parsed

func get_task(task_id: String) -> Dictionary:
	for task: Dictionary in presets:
		if task["id"] == task_id:
			return task
	return presets[1] if presets.size() > 1 else {}

func evaluate() -> Dictionary:
	return Verifier.verify(get_task(GameState.get_value("current_task")), GameState.snapshot(), EventLogger.events)
