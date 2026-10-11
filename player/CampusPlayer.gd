extends "res://player/Player.gd"
## V6 human camera; the original body, collisions and Agent movement stay shared.
var human_camera_enabled := false
var orbit_yaw := 0.0
var orbit_pitch := 0.0
var orbit_zoom := 1.0

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
