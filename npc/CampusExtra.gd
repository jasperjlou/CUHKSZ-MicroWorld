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
	if variant in [4, 8]:
		K.box(model, Vector3(0.42, 1.04, 0.45), Vector3(0.17, 0.26, 0.05), Color("94b5b0"))
	var roles := ["reading_notice", "reading_notice", "courtyard_rest", "corridor_walking", "photo_waiting", "waiting_friend", "conversation", "waiting_friend", "checking_registration", "foyer_walking", "conversation", "dinner_waiting"]
	set_meta("semantic_tags", ["background_student", "formal_attire", "noninteractive", roles[variant]])
	if variant in [0, 1, 8]: model.rotation.y = PI
	if variant in [5, 6]: model.rotation.y = -PI/2 if variant == 5 else PI/2
	if variant % 3 == 1:
		K.box(model.get_node("Head"), Vector3(0,0.18,-0.20), Vector3(0.44,0.50,0.14), Color("383630"))
	model.scale.x *= 0.92 if variant % 2 == 0 else 1.04
	model.scale.y *= 0.96 if variant % 3 == 0 else 1.02

func _process(delta: float) -> void:
	if not GameState.get_flag("started") or GameState.get_flag("paused") or GameState.get_flag("modal_open") or GameState.get_flag("game_finished"):
		return
	phase += delta
	if variant in [3, 9]:
		position.z = origin.z + sin(phase * 0.22) * (4.0 if variant == 3 else 1.6)
		model.rotation.y = PI if cos(phase * 0.22) < 0 else 0
		K.pose_walk(model, sin(phase * 4) * 0.2)
	else:
		model.get_node("Head").rotation.y = sin(phase * 0.45) * 0.16
		model.get_node("RightArm").rotation.x = -0.65 if variant in [4, 8] else (sin(phase * 0.7) * 0.23 if variant in [5,6,10] else 0.02)
