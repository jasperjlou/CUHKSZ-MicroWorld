extends Node
## Small synthesized cues; no external sound assets or downloads.
var speaker: AudioStreamPlayer
var step_speaker: AudioStreamPlayer

func _ready() -> void:
	add_to_group("sound_cues")
	speaker = AudioStreamPlayer.new()
	speaker.volume_db = -22
	add_child(speaker)
	step_speaker = AudioStreamPlayer.new()
	step_speaker.volume_db = -32
	add_child(step_speaker)
	EventBus.event_emitted.connect(_on_event)

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
	for output in [speaker, step_speaker]:
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
