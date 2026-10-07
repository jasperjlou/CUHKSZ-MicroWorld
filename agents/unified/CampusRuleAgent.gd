extends RefCounted
# Only public observations/actions; no environment/graph/verifier access.
var goals: Array=[]
var index:=0
func reset_episode() -> void:
	goals.clear();index=0
func choose(observation: Dictionary,available: Array) -> Dictionary:
	if goals.is_empty():goals=observation.current_task.destinations.duplicate()
	if observation.current_task.id=="photo_event" and observation.current_location=="photo_student" and not observation.event_state.photo_completed:
		for a: Dictionary in available:
			if a.type=="interact":return a.duplicate()
	if index<goals.size():
		for a: Dictionary in available:
			if a.type=="navigate_to" and a.target==goals[index]:index+=1;return a.duplicate()
	return {}
