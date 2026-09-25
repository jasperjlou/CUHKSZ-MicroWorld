extends CharacterBody3D
const Kit := preload("res://world/MeshKit.gd")
const WALK_SPEED := 5.1
const JOG_SPEED := 8.3
const PHONE_SPEED := 2.4
const CAMERA_OFFSET := Vector3(0, 9.4, 12.5)
var agent_controlled := false
var navigation_direction := Vector2.ZERO
var moving := false
var model: Node3D
var phone_mesh: MeshInstance3D
var camera: Camera3D
var step_phase := 0.0
var photo_mode := false
var photo_target := Vector3.ZERO
var footstep_remaining := 0.0

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	var collider := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.38 * Kit.CHARACTER_SCALE
	shape.height = 1.9 * Kit.CHARACTER_SCALE
	collider.shape = shape
	collider.position.y = shape.height / 2.0
	add_child(collider)
	model = Kit.person(self, Color("f5cc73"))
	phone_mesh = Kit.box(model, Vector3(0.24, 1.30, 0.47), Vector3(0.22, 0.32, 0.07), Color("7fd3d1"))
	phone_mesh.material_override = Kit.material(Color("7fd3d1"), true)
	phone_mesh.visible = false
	camera = Camera3D.new()
	camera.top_level = true
	camera.fov = 49
	camera.far = 230
	add_child(camera)
	camera.current = true
	update_camera(1.0, true)

func _physics_process(delta: float) -> void:
	if GameState.get_flag("paused"):
		return
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back") if GameState.can_move() else Vector2.ZERO
	if agent_controlled:
		input = navigation_direction if GameState.can_move() else Vector2.ZERO
	var direction := Vector3(input.x, 0, input.y)
	var speed := PHONE_SPEED if GameState.get_flag("phone_open") else (JOG_SPEED if not agent_controlled and Input.is_action_pressed("jog") else WALK_SPEED)
	var acceleration := 42.0 if direction.length() > 0 else 65.0
	velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)
	if not GameState.can_move():
		velocity.x = 0
		velocity.z = 0
	velocity.y = 0.0 if is_on_floor() else velocity.y - 18.0 * delta
	move_and_slide()
	moving = Vector2(velocity.x, velocity.z).length() > 0.15
	if moving:
		model.rotation.y = lerp_angle(model.rotation.y, atan2(direction.x, direction.z), minf(delta * 12, 1))
		step_phase += delta * speed * 5 / Kit.CHARACTER_SCALE
		model.position.y = absf(sin(step_phase)) * 0.055 * Kit.CHARACTER_SCALE
	else:
		model.position.y = 0
	Kit.pose_walk(model, sin(step_phase) * 0.32 if moving else 0.0)
	phone_mesh.visible = GameState.get_flag("phone_open")
	var phone_open := GameState.get_flag("phone_open")
	model.get_node("Head").rotation.x = lerpf(model.get_node("Head").rotation.x, 0.38 if phone_open else 0.0, minf(delta * 9, 1))
	model.get_node("RightArm").rotation.x = lerpf(model.get_node("RightArm").rotation.x, -1.15 if phone_open else (sin(step_phase) * 0.22 if moving else 0.0), minf(delta * 12, 1))
	footstep_remaining -= delta
	if moving and is_on_floor() and footstep_remaining <= 0:
		footstep_remaining = 0.38 if speed > WALK_SPEED else 0.52
		get_tree().call_group("sound_cues", "step")
	GameState.set_value("player_speed_state", "phone" if moving and GameState.get_flag("phone_open") else ("walking" if moving else "idle"))
	update_camera(delta)

func update_camera(delta: float, snap: bool = false) -> void:
	var target := global_position + CAMERA_OFFSET
	var look_target := global_position + Vector3(0, 1.05, -2)
	if photo_mode:
		target = photo_target + Vector3(0, 5.2, 10.5)
		look_target = photo_target + Vector3(0, 1.6, 0)
	# Pull in before solid architecture rather than letting walls fill the view.
	var anchor := global_position + Vector3(0, 2.4, 0)
	if not photo_mode:
		var query := PhysicsRayQueryParameters3D.create(anchor, target, 1)
		var hit := get_world_3d().direct_space_state.intersect_ray(query)
		if not hit.is_empty():
			target = hit.position + hit.normal * 0.4
	var blended := target if snap else camera.global_position.lerp(target, 1.0 - exp(-9.0 * delta))
	if not photo_mode:
		var obstruction := get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(anchor, blended, 1))
		if not obstruction.is_empty():
			blended = obstruction.position + obstruction.normal * 0.4
	camera.global_position = blended
	var desired := camera.global_transform.looking_at(look_target, Vector3.UP)
	camera.quaternion = desired.basis.get_rotation_quaternion() if snap else camera.quaternion.slerp(desired.basis.get_rotation_quaternion(), 1.0 - exp(-7.0 * delta))

func begin_photo(target: Vector3) -> void:
	photo_target = target
	photo_mode = true
	model.hide()

func end_photo() -> void:
	photo_mode = false
	model.show()
