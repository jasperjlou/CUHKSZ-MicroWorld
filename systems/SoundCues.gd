extends Node
## Small synthesized cues; no external sound assets or downloads.
var speaker: AudioStreamPlayer
var step_speaker: AudioStreamPlayer
var air: AudioStreamPlayer
var room: AudioStreamPlayer

func _ready() -> void:
	add_to_group("sound_cues")
	speaker = AudioStreamPlayer.new()
	speaker.volume_db = -22
	add_child(speaker)
	step_speaker = AudioStreamPlayer.new()
	step_speaker.volume_db = -32
	add_child(step_speaker)
	EventBus.event_emitted.connect(_on_event)
	if DisplayServer.get_name() != "headless":
		air = _ambience(false)
		room = _ambience(true)

func _ambience(indoors: bool) -> AudioStreamPlayer:
	var output := AudioStreamPlayer.new()
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var count := 88200
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	# Periodic low-level harmonic room tone / wind, wholly synthesized.
	for i: int in count:
		var t := float(i) / stream.mix_rate
		var sample := sin(TAU * 83 * t) * 0.18 + sin(TAU * 127 * t) * 0.12
		if indoors:
			sample += sin(TAU * 220 * t) * 0.14 + sin(TAU * 330 * t) * 0.08
		else:
			sample += sin(TAU * 311 * t + sin(TAU * 0.5 * t)) * 0.07
		bytes.encode_s16(i * 2, int(sample * 12000))
	stream.data = bytes
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = count
	output.stream = stream
	output.volume_db = -48
	add_child(output)
	output.play()
	return output

func _process(delta: float) -> void:
	if not is_instance_valid(air): return
	var world := get_tree().current_scene
	if world == null or not is_instance_valid(world.get("player")): return
	var z: float = world.player.global_position.z
	var quiet := not GameState.get_flag("started") or GameState.get_flag("paused")
	air.volume_db = lerpf(air.volume_db, -60.0 if quiet else -44.0, minf(delta * 3, 1))
	room.volume_db = lerpf(room.volume_db, -39.0 if z < -43 and not quiet else -65.0, minf(delta * 2, 1))

func _on_event(record: Dictionary) -> void:
	match record["event"]:
		"FRIEND_MESSAGE_RECEIVED": tone(780.0, 0.20)
		"FRIEND_REPLIED": tone(580.0, 0.10)
		"PHOTO_SHUTTER": tone(1800.0, 0.08)
		"HIGH_TABLE_REACHED": tone(880.0, 0.28)
		"PHONE_OPENED", "PHONE_CLOSED": tone(420.0, 0.045)

func click() -> void:
	tone(600.0, 0.035)

func _exit_tree() -> void:
	for output in [speaker, step_speaker, air, room]:
		if is_instance_valid(output):
			output.stop()
			output.stream = null

func step() -> void:
	tone(95.0, 0.055, step_speaker)

func tone(frequency: float, duration: float, output: AudioStreamPlayer = null) -> void:
	# Headless logic runs do not have an audible output; keep playback to windowed runs.
	if DisplayServer.get_name() == "headless":
		return
	var sample_rate := 22050
	var length := int(sample_rate * duration)
	var bytes := PackedByteArray()
	bytes.resize(length * 2)
	for i in range(length):
		var t := float(i) / sample_rate
		var envelope := minf(t * 120.0, 1.0) * (1.0 - float(i) / length)
		var sample := sin(TAU * frequency * t) * envelope * 18000.0
		bytes.encode_s16(i * 2, int(sample))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = bytes
	var target := speaker if output == null else output
	target.stream = stream
	target.play()
