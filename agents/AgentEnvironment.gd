extends Node
# Attach to the scene-tree root, outside MainWorld, so reset replaces every
# transient world/NPC/UI instance while preserving this API object.
signal episode_reset(seed_value: int)
const TARGETS = preload("res://world/WorldRegion.gd").TARGETS
const PUBLIC_EVENTS := ["TEACHER_PASSED", "PHONE_OPENED", "PHONE_CLOSED", "FRIEND_MESSAGE_RECEIVED", "FRIEND_REPLIED", "PHOTO_REQUESTED", "PHOTO_ACCEPTED", "PHOTO_DECLINED", "PHOTO_SHUTTER", "PHOTO_COMPLETED", "TEACHER_NOTICED_PLAYER", "TEACHER_WARNED_PLAYER", "TEACHER_SECOND_WARNING", "TEACHER_ACKNOWLEDGED", "HIGH_TABLE_REACHED", "DEADLINE_PASSED", "GAME_FINISHED"]
var decision_gated := false
var world: Node3D
var executing := false
var resetting := false
var generation := 0
var seed_value := 0
var observed_events: Array = []
var helped := false
var warnings := 0
var steps := 0
var invalid_actions := 0

func _ready() -> void:
	EventBus.event_emitted.connect(_on_event)

func _on_event(record: Dictionary) -> void:
	if resetting or record.event not in PUBLIC_EVENTS:
		return
	# Deliberate allowlist: never expose perception rays, verifier, cooldowns,
	# state snapshots or internal event payloads through observations/step.
	observed_events.append({"event":record.event, "actor":record.actor, "game_time":record.game_time})
	if record.event == "PHOTO_COMPLETED":
		helped = true
	if record.event in ["TEACHER_WARNED_PLAYER", "TEACHER_SECOND_WARNING"]:
		warnings += 1

func reset(task_id: String = "", episode_seed: Variant = null) -> Dictionary:
	if resetting:
		return {"valid":false, "reason":"reset_in_progress"}
	var tasks := preload("res://systems/TaskSystem.gd").new()
	if task_id.is_empty():
		task_id = "careful_student"
	if not tasks.presets.any(func(t): return t.id == task_id):
		return {"valid":false, "reason":"unknown_task"}
	resetting = true
	generation += 1
	if is_instance_valid(world):
		world.player.navigation_direction = Vector2.ZERO
		if GameState.get_flag("started") and not is_done():
			EventBus.emit_event("RUN_ABORTED", "agent", {"reason":"reset"})
	world = null
	executing = false
	steps = 0
	invalid_actions = 0
	helped = false
	warnings = 0
	observed_events.clear()
	seed_value = int(episode_seed) if episode_seed != null else 0
	get_tree().reload_current_scene()
	await get_tree().process_frame
	await get_tree().process_frame
	world = get_tree().current_scene
	world.agent_mode = true
	world.player.agent_controlled = true
	resetting = false
	world.start_run(task_id)
	_gate(true)
	episode_reset.emit(seed_value)
	return observe()

func observe() -> Dictionary:
	if not is_instance_valid(world) or resetting:
		return {}
	var entities: Array = []
	var nearby: Array = []
	for actor in world.actors:
		var distance: float = world.player.global_position.distance_to(actor.global_position)
		var ray := PhysicsRayQueryParameters3D.create(world.player.global_position + Vector3(0, 1.6, 0), actor.global_position + Vector3(0, 1.6, 0), 1)
		if distance <= 18 and world.get_world_3d().direct_space_state.intersect_ray(ray).is_empty():
			entities.append({"id":actor.actor_id, "name":actor.display_name, "distance":snappedf(distance, 0.01)})
			if actor.nearby():
				nearby.append(actor.actor_id)
	var task: Dictionary = world.tasks.get_task(GameState.get_value("current_task"))
	var messages: Array = []
	if GameState.get_flag("phone_open"):
		messages.append({"from":"friend_01", "text":"你到哪了？高桌晚宴快开始了，我在门口等你。", "replied":GameState.get_flag("responded_to_friend")})
	var pos: Vector3 = world.player.global_position
	var options: Array = []
	for option in world.dialogue_options:
		options.append(option.text)
	return {
		"schema_version":1,
		"region":preload("res://world/WorldRegion.gd").region_at(pos),
		"known_regions":preload("res://world/WorldRegion.gd").KNOWN_REGIONS.duplicate(true),
		"game_time":GameState.format_time(GameState.get_value("current_game_time"), true),
		"elapsed_seconds":snappedf(GameState.get_value("elapsed"), 0.001),
		"location":GameState.get_value("current_location"),
		"position":[snappedf(pos.x, 0.01), snappedf(pos.y, 0.01), snappedf(pos.z, 0.01)],
		"phone_open":GameState.get_flag("phone_open"),
		"current_task":{"id":task.id, "name":task.name, "description":task.description},
		"visible_entities":entities, "nearby_interactions":nearby,
		"messages":messages, "friend_replied":GameState.get_flag("responded_to_friend"),
		"personal_history":{"photo_completed":helped, "warnings_heard":warnings},
		"dialogue":{"speaker":world.dialogue_actor, "text":world.dialogue_words, "options":options},
		"recent_events":observed_events.slice(maxi(0, observed_events.size() - 8)).duplicate(true),
		"done":is_done()
	}

func get_available_actions() -> Array:
	if not is_instance_valid(world) or resetting or executing or is_done():
		return []
	if not world.dialogue_actor.is_empty():
		if world.dialogue_actor == "photo_student" and world.dialogue_options.size() == 2:
			return [{"type":"accept_photo_request"}, {"type":"decline_photo_request"}]
		if world.dialogue_actor == "friend_01":
			return [{"type":"enter_high_table"}]
		return [{"type":"continue_dialogue"}]
	if not GameState.can_move():
		return []
	var actions: Array = []
	for target: String in TARGETS:
		if _flat_distance(world.player.position, TARGETS[target]) > 0.4:
			actions.append({"type":"move_to", "target":target})
	for actor in world.actors:
		if actor.nearby():
			actions.append({"type":"talk_to", "target":actor.actor_id})
	actions.append({"type":"close_phone" if GameState.get_flag("phone_open") else "open_phone"})
	if GameState.get_flag("phone_open") and not GameState.get_flag("responded_to_friend"):
		actions.append({"type":"reply_to_friend"})
	actions.append({"type":"wait"})
	return actions

func step(action: Dictionary) -> Dictionary:
	var available := get_available_actions()
	var reason := ""
	if resetting or not is_instance_valid(world):
		reason = "environment_not_ready"
	elif executing:
		reason = "action_in_progress"
	elif is_done():
		reason = "episode_finished"
	elif action not in available:
		reason = "action_not_available"
	if not reason.is_empty():
		invalid_actions += 1
		EventBus.emit_event("AGENT_INVALID_ACTION", "agent", {"action":action, "reason":reason})
		return {"valid":false, "reason":reason, "observation":observe(), "events":[], "done":is_done(), "result":get_result()}
	executing = true
	_gate(false)
	steps += 1
	var token := generation
	var event_start := observed_events.size()
	EventBus.emit_event("AGENT_ACTION", "agent", action)
	var failure := ""
	match action.type:
		"move_to":
			failure = await _navigate(action.target, token)
		"open_phone", "close_phone":
			world.toggle_phone()
		"reply_to_friend":
			world.reply_to_friend()
		"talk_to":
			for actor in world.actors:
				if actor.actor_id == action.target:
					actor.begin_interaction()
			await _advance(0.5, token)
		"accept_photo_request", "decline_photo_request", "continue_dialogue", "enter_high_table":
			world.choose_dialogue(1 if action.type == "decline_photo_request" else 0)
			if action.type == "accept_photo_request":
				await _advance(3.4, token)
		"wait":
			await _advance(5.0, token)
	if token != generation:
		return {"valid":true, "interrupted":true, "reason":"episode_reset", "events":[], "done":false}
	await _advance(0.15, token)
	if token != generation:
		return {"valid":true, "interrupted":true, "reason":"episode_reset", "events":[], "done":false}
	executing = false
	_gate(true)
	return {"valid":true, "execution_error":failure, "observation":observe(), "events":observed_events.slice(event_start).duplicate(true), "done":is_done(), "result":get_result()}

func _advance(seconds: float, token: int) -> void:
	var frames := int(ceil(seconds * Engine.physics_ticks_per_second))
	for i in frames:
		if token != generation or is_done():
			return
		await get_tree().physics_frame

func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()

func _navigate(target: String, token: int) -> String:
	var points: Array[Vector3] = []
	var pos: Vector3 = world.player.position
	# Fixed corridor graph for the existing compact campus. All segments use
	# ordinary move_and_slide, collision, clock, phone speed and NPC perception.
	if pos.x > 5:
		points.append(Vector3(8.64, 0, -29.0))
		points.append(Vector3(0, 0, -29.0))
	elif absf(pos.x) > 0.3:
		points.append(Vector3(0, 0, pos.z))
	if target == "photo_spot":
		points.append(Vector3(0, 0, -29.0))
		points.append(Vector3(8.64, 0, -29.0))
	points.append(TARGETS[target])
	for point in points:
		var best := INF
		var stalled := 0
		for frame in 9000:
			if token != generation:
				return "episode_reset"
			if is_done():
				world.player.navigation_direction = Vector2.ZERO
				return ""
			var distance := _flat_distance(world.player.position, point)
			if distance <= 0.18:
				break
			if distance < best - 0.02:
				best = distance
				stalled = 0
			else:
				stalled += 1
			if stalled > 180 or frame == 8999:
				world.player.navigation_direction = Vector2.ZERO
				return "navigation_blocked"
			world.player.navigation_direction = Vector2(point.x - world.player.position.x, point.z - world.player.position.z).normalized()
			await get_tree().physics_frame
	world.player.navigation_direction = Vector2.ZERO
	return ""

func is_done() -> bool:
	return is_instance_valid(world) and GameState.get_flag("game_finished")

func get_result() -> Dictionary:
	return world.last_result.duplicate(true) if is_done() else {}

func _gate(waiting: bool) -> void:
	if decision_gated and is_instance_valid(world):
		world.process_mode = Node.PROCESS_MODE_DISABLED if waiting else Node.PROCESS_MODE_INHERIT
