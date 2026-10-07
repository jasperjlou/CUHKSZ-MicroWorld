extends "res://systems/SoundCues.gd"
var world: Node3D
func _process(delta: float) -> void:
	if not is_instance_valid(air):return
	var id: String=world.interiors.active_id
	air.volume_db=lerpf(air.volume_db,-65.0 if not id.is_empty() else -46.0,delta*3)
	var level: float=-49.0 if id=="library" else -43.0 if id in ["student_centre","sports_hall"] else -46.0
	room.volume_db=lerpf(room.volume_db,level if not id.is_empty() else -65.0,delta*3)
func step() -> void:
	var id: String=world.interiors.active_id
	tone(72.0 if id=="ling" else 125.0 if id=="sports_hall" else 95.0,.055,step_speaker)
