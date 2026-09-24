extends RefCounted
# Policy consumes only public API values. No world, GameState or UI access.
func reset_episode(_seed_value: int) -> void:
	pass

func choose(observation: Dictionary, actions: Array) -> Dictionary:
	for kind in ["accept_photo_request", "enter_high_table", "continue_dialogue"]:
		var found := _find(actions, kind)
		if not found.is_empty():
			return found
	if observation.phone_open:
		return _find(actions, "close_phone" if observation.friend_replied else "reply_to_friend")
	if not observation.friend_replied:
		return _find(actions, "open_phone")
	if not observation.personal_history.photo_completed:
		var talk := _find(actions, "talk_to", "photo_student")
		return talk if not talk.is_empty() else _find(actions, "move_to", "photo_spot")
	var friend := _find(actions, "talk_to", "friend_01")
	return friend if not friend.is_empty() else _find(actions, "move_to", "high_table")

func _find(actions: Array, kind: String, target: String = "") -> Dictionary:
	for action: Dictionary in actions:
		if action.type == kind and (target.is_empty() or action.get("target") == target):
			return action.duplicate(true)
	return {}
