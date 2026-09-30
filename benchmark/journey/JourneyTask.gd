extends RefCounted
## Privileged task setup, never passed to a provider.
static func job_path() -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--journey-job="):
			return arg.trim_prefix("--journey-job=")
	return ""

static func load_job() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(job_path()))

static func configure(base: Dictionary, job: Dictionary) -> Dictionary:
	var task: Dictionary = job.task
	base.task_id = task.task_id
	base.title = task.title
	base.description = task.instruction
	base.start = task.spawn
	base.required_visits = task.required_visits.duplicate()
	base.initial_time = task.start_time
	base.event.location = task.destination
	base.event.start_time = task.event_time
	base.event.end_time = task.event_end
	base.transport_scenarios["benchmark"] = task.transport.duplicate(true)
	base.transport_scenarios.benchmark.scenario_seed = job.seed
	base.transport_scenarios.benchmark.title_zh = "评测接驳（虚构时刻）"
	Engine.set_meta("lake_transport_scenario","benchmark")
	return base
