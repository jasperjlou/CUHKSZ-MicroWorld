extends Node3D
# Deterministic, cosmetic campus life. No policy, quest state or network calls.
const K := preload("res://world/MeshKit.gd")
var variant := 0
var model: Node3D
var origin := Vector3.ZERO
var phase := 0.0

func _ready() -> void:
	origin = position
	phase = variant * 0.7
	var colors := [Color("354453"),Color("6c6679"),Color("b8b5a5"),Color("365458")]
	model = K.person(self, colors[variant % 4], "gown" if variant % 3 == 0 else "formal")
	model.rotation.y = 0.7 if variant % 2 == 0 else -1.9
	if variant % 4 == 0:
		K.box(model, Vector3(0.42, 1.2, 0.38), Vector3(0.17, 0.26, 0.05), Color("94b5b0"))
	set_meta("semantic_tags", ["background_student", "formal_attire", "noninteractive"])

func _process(delta: float) -> void:
	if not GameState.get_flag("started") or GameState.get_flag("paused") or GameState.get_flag("modal_open") or GameState.get_flag("game_finished"):
		return
	phase += delta
	if variant in [3, 9]:
		position.z = origin.z + sin(phase * 0.25) * 1.2
		model.rotation.y = PI if cos(phase * 0.25) < 0 else 0
		K.pose_walk(model, sin(phase * 4) * 0.2)
	else:
		model.get_node("Head").rotation.y = sin(phase * 0.45) * 0.16
		model.get_node("RightArm").rotation.x = -0.65 if variant % 4 == 0 else sin(phase * 0.7) * 0.1
