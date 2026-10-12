extends "res://player/Player.gd"
## V6 human camera; the original body, collisions and Agent movement stay shared.
var human_camera_enabled := false
var orbit_yaw := 0.0
var orbit_pitch := 0.0
var orbit_zoom := 1.0
const CAMERA_CLEARANCE := 0.24
var camera_probe: SphereShape3D

func turn_camera(relative: Vector2) -> void:
	orbit_yaw = wrapf(orbit_yaw - relative.x * 0.006, -PI, PI)
	orbit_pitch = clampf(orbit_pitch + relative.y * 0.005, -0.42, 0.45)

func zoom_camera(direction: float) -> void:
	orbit_zoom = clampf(orbit_zoom * pow(0.9, direction), 0.55, 1.5)

func _physics_process(delta: float) -> void:
	var base_offset := camera_offset
	if human_camera_enabled and not agent_controlled and not photo_mode:
		var horizontal := Vector2(base_offset.x, base_offset.z).length()
		var pitch := clampf(atan2(base_offset.y, horizontal) + orbit_pitch, 0.12, 1.10)
		var distance := base_offset.length() * orbit_zoom
		camera_offset = Vector3(0, sin(pitch) * distance, cos(pitch) * distance).rotated(Vector3.UP, orbit_yaw)
	super._physics_process(delta)
	camera_offset = base_offset

func safe_camera_point(anchor: Vector3, destination: Vector3) -> Vector3:
	if camera_probe == null:
		camera_probe = SphereShape3D.new()
		camera_probe.radius = CAMERA_CLEARANCE
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = camera_probe
	query.transform = Transform3D(Basis.IDENTITY, anchor)
	query.motion = destination - anchor
	query.collision_mask = 1
	query.margin = 0.02
	var fractions := get_world_3d().direct_space_state.cast_motion(query)
	return anchor + query.motion * maxf(0, fractions[0] - 0.015)

func update_camera(delta: float, snap: bool = false) -> void:
	if not human_camera_enabled or agent_controlled or photo_mode:
		if is_instance_valid(model) and not photo_mode:model.show()
		super.update_camera(delta, snap)
		return
	# The avatar is 1.88 m tall. Keep the boom origin below its head, including
	# underneath the library stair slab; the old 2.4 m ray started above it.
	var anchor := global_position + Vector3.UP * 1.5
	var target := safe_camera_point(anchor, global_position + camera_offset)
	var blended := target if snap else camera.global_position.lerp(target, 1.0 - exp(-9.0 * delta))
	# Recheck the smoothed boom as the body descends or turns around a corner.
	# The swept sphere also protects the near-plane edges, not only the centre ray.
	camera.global_position = safe_camera_point(anchor, blended)
	var back := Vector3(camera_offset.x, 0, camera_offset.z).normalized()
	var look_target := anchor - back * 2.5
	var desired := camera.global_transform.looking_at(look_target, Vector3.UP)
	camera.quaternion = desired.basis.get_rotation_quaternion() if snap else camera.quaternion.slerp(desired.basis.get_rotation_quaternion(), 1.0 - exp(-9.0 * delta))
	# A close wall can retract the camera into the avatar; hide only its mesh.
	var body_distance := camera.global_position.distance_to(anchor)
	if body_distance < 2.4:model.hide()
	elif body_distance > 2.7:model.show()
