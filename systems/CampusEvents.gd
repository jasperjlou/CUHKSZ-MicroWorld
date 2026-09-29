extends RefCounted
## Generic schedule lifecycle is separate from a particular player's task outcome.
signal status_changed(id: String, before: String, after: String)
var events: Dictionary = {}

func reset(definitions: Array, now: float) -> void:
	events.clear()
	for definition: Dictionary in definitions:
		assert(definition.has("id") and definition.has("title") and definition.has("location"))
		assert(float(definition.end_time) > float(definition.start_time))
		var event := definition.duplicate(true)
		event.status = "upcoming"
		event.arrival_time = null
		events[event.id] = event
	update(now)

func update(now: float) -> void:
	for id: String in events:
		var event: Dictionary = events[id]
		var status := "upcoming" if now < event.start_time else "active"
		if now >= event.end_time:
			status = "completed" if event.arrival_time != null and event.arrival_time < event.end_time else "missed"
		if status != event.status:
			var previous: String = event.status
			event.status = status
			status_changed.emit(id,previous,status)

func observe(id: String, now: float) -> Dictionary:
	var result: Dictionary = events[id].duplicate(true)
	result.time_remaining = maxf(0,float(result.start_time)-now)
	result.seconds_until_end = maxf(0,float(result.end_time)-now)
	result.destination = result.location
	return result

func attend(id: String, now: float, near_start_seconds: float = 60.0) -> Dictionary:
	var event: Dictionary = events[id]
	if event.arrival_time == null:
		event.arrival_time = now
	update(now)
	return evaluate(event,float(event.arrival_time),near_start_seconds)

static func evaluate(event: Dictionary, arrival: float, near_start_seconds: float = 60.0) -> Dictionary:
	var status := "early"
	if arrival >= float(event.end_time):
		status = "missed"
	elif arrival > float(event.start_time):
		status = "late"
	elif arrival >= float(event.start_time)-near_start_seconds:
		status = "on_time"
	return {"success":arrival <= float(event.start_time),"arrival_status":status,"arrival_time":arrival,"event_start_time":event.start_time,"event_end_time":event.end_time,"lateness":maxf(0,arrival-float(event.start_time)),"earliness":maxf(0,float(event.start_time)-arrival)}
