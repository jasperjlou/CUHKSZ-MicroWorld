extends RefCounted
## Privileged evaluator. Never trusts model text or world.result.success.
static func snapshot(world: Node, task: Dictionary) -> Dictionary:
	var event: Dictionary = world.event_system.events[world.task_config.event.id]
	return {"distance_to_destination":world.player.position.distance_to(world.Layout.position_of(world.records[task.destination])),"inspected_destination":task.destination in world.inspected,"arrival_time":event.arrival_time,"completed_visits":world.completed_visits.duplicate(),"invalid_actions":world.invalid_actions,"recovery_count":world.recovery_count,"journey":world.journey_metrics(),"transport":world.transport.metrics()}

static func evaluate(state: Dictionary, task: Dictionary, termination: String) -> Dictionary:
	var arrival: Variant = state.arrival_time
	var timing := {"arrival_status":"not_arrived","lateness":0.0}
	if arrival != null:
		timing = preload("res://systems/CampusEvents.gd").evaluate({"start_time":task.event_time,"end_time":task.event_end},float(arrival),60.0)
	var reason: Variant = null
	if not termination.is_empty():
		reason = termination
	elif state.distance_to_destination > 3.3 or (task.verifier.require_interaction and not state.inspected_destination) or arrival == null:
		reason = "destination_or_interaction_missing"
	elif not task.required_visits.all(func(id): return id in state.completed_visits):
		reason = "required_visit_missing"
	elif timing.arrival_status not in task.verifier.accepted_arrivals:
		reason = "missed_event" if timing.arrival_status == "missed" else "arrival_not_accepted"
	elif state.invalid_actions > task.verifier.max_invalid_actions:
		reason = "invalid_action_limit"
	elif state.recovery_count > 0:
		reason = "boundary_recovery"
	elif task.verifier.get("require_shuttle",false) and not state.transport.shuttle_used:
		reason = "shuttle_required"
	return {"success":reason == null,"failure_reason":reason,"arrival_time":arrival,"event_state":timing.arrival_status,"lateness_seconds":timing.lateness,"timeout":termination in ["step_limit","simulation_timeout","wall_timeout"],"verifier_version":"journey-verifier-v1"}
