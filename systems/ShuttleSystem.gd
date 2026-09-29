extends RefCounted
## Schedule only: no task, scene, rendering or movement dependencies. Times are game seconds.
signal state_changed(before: String, after: String)
var definition: Dictionary = {}
var state := "scheduled"
var scheduled_arrival := 0.0
var actual_arrival := 0.0
var departure_time := 0.0
var destination_arrival := 0.0
var delay := 0.0
var occupied := false

func reset(config: Dictionary, initial_time: float) -> void:
	definition = config.duplicate(true)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(config.get("scenario_seed",42))
	delay = float(config.get("delay",0)) + rng.randi_range(0,int(config.get("delay_jitter",0)))
	scheduled_arrival = initial_time + float(config.wait_until_arrival)
	actual_arrival = scheduled_arrival + delay
	departure_time = actual_arrival + float(config.boarding_duration)
	destination_arrival = departure_time + float(config.ride_duration)
	occupied = false
	state = "scheduled"
	update(initial_time)

func update(now: float) -> void:
	var next := "scheduled"
	if now >= destination_arrival:
		next = "arrived"
	elif now >= departure_time:
		next = "in_transit"
	elif now >= actual_arrival:
		next = "boarding"
	elif now >= actual_arrival-float(definition.get("approach_duration",30)):
		next = "approaching"
	if state == next:
		return
	# Departure is an explicit transition event; in_transit is the sustained state.
	if state == "boarding" and next == "in_transit":
		_set_state("departed")
	_set_state(next)

func _set_state(next: String) -> void:
	var before := state
	state = next
	state_changed.emit(before,next)

func can_board() -> bool:
	return state == "boarding" and not occupied and int(definition.get("capacity",1)) > 0

func board(now: float) -> bool:
	update(now)
	if not can_board():
		return false
	occupied = true
	# Capacity-one prototype departs after a short dwell once its passenger boards.
	departure_time = minf(departure_time,now+float(definition.get("dispatch_duration",20)))
	destination_arrival = departure_time+float(definition.ride_duration)
	return true

func observe(now: float) -> Dictionary:
	var known := str(definition.get("information_mode","known")) == "known"
	var board_then_depart := minf(departure_time,maxf(now,actual_arrival)+float(definition.get("dispatch_duration",20)))
	return {"id":definition.id,"route":definition.route,"state":state,"scheduled_arrival":scheduled_arrival,"actual_arrival":actual_arrival if known or state in ["boarding","departed","in_transit","arrived"] else null,"estimated_delay":delay if known else null,"information_mode":"known" if known else "partial","estimated_wait":maxf(0,actual_arrival-now) if known else null,"estimated_total_time":maxf(0,board_then_depart-now)+float(definition.ride_duration) if known and state in ["scheduled","approaching","boarding"] else null,"boarding_duration":definition.boarding_duration,"dispatch_duration":definition.get("dispatch_duration",20),"ride_duration":definition.ride_duration,"estimated_ride_time":definition.ride_duration,"departure_time":departure_time if known or state == "boarding" else null,"capacity":definition.capacity,"available":can_board(),"confidence":"placeholder","prototype":true}
