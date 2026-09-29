extends Node
signal write_failed
var events: Array[Dictionary] = []
var run_path := ""
var summary_path := ""
var last_completed_path := ""
var io_error := false
var run_serial := 0
var log_directory := "user://logs"

func _ready() -> void:
	if "--qa" in OS.get_cmdline_user_args() or "--qa-render" in OS.get_cmdline_user_args() or "--polish-qa" in OS.get_cmdline_user_args() or "--polish-render" in OS.get_cmdline_user_args() or "--lake-qa" in OS.get_cmdline_user_args() or "--lake-render" in OS.get_cmdline_user_args() or "--event-qa" in OS.get_cmdline_user_args() or "--event-render" in OS.get_cmdline_user_args() or "--shuttle-qa" in OS.get_cmdline_user_args() or "--shuttle-render" in OS.get_cmdline_user_args() or "--journey-qa" in OS.get_cmdline_user_args() or "--journey-render" in OS.get_cmdline_user_args() or "--connector-qa" in OS.get_cmdline_user_args() or "--connector-render" in OS.get_cmdline_user_args():
		log_directory = "user://qa_logs"
	EventBus.event_emitted.connect(_on_event)

func begin_run() -> void:
	events.clear()
	io_error = false
	run_serial += 1
	DirAccess.make_dir_recursive_absolute(log_directory)
	var stamp := Time.get_datetime_string_from_system().replace(":", "-")
	var identifier := "%s_%s_%s_%s" % [stamp, OS.get_process_id(), Time.get_ticks_usec(), run_serial]
	run_path = log_directory + "/run_" + identifier + ".json"
	summary_path = log_directory + "/run_" + identifier + "_summary.json"
	_save(run_path, events)

func prepare_next_run() -> void:
	# Preserve the last completed file for the viewer, but never display old events as a fresh run.
	events.clear()
	run_path = ""
	summary_path = ""
	io_error = false

func _on_event(record: Dictionary) -> void:
	if run_path.is_empty():
		return
	events.append(record.duplicate(true))
	# Every semantic event is persisted, including interrupted runs.
	_save(run_path, events)

func finish_run(result: Dictionary) -> void:
	_save(summary_path, {"schema_version": 1, "result": result, "state": GameState.snapshot(), "event_log": run_path})
	last_completed_path = run_path

func _save(path: String, content: Variant) -> void:
	if path.is_empty():
		io_error = true
		write_failed.emit()
		return
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		io_error = true
		write_failed.emit()
		return
	file.store_string(JSON.stringify(content, "\t", false))
	file.flush()
	file.close()
	var error := DirAccess.rename_absolute(path + ".tmp", path)
	if error != OK:
		io_error = true
		write_failed.emit()

func read_last_run() -> Array:
	if last_completed_path.is_empty() or not FileAccess.file_exists(last_completed_path):
		return []
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(last_completed_path))
	return parsed if parsed is Array else []
