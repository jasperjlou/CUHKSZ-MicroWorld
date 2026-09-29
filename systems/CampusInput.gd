extends RefCounted

static func configure() -> void:
	var bindings := {"move_forward":KEY_W,"move_back":KEY_S,"move_left":KEY_A,"move_right":KEY_D,"jog":KEY_SHIFT,"interact":KEY_E,"phone":KEY_TAB,"pause_game":KEY_ESCAPE,"restart":KEY_R,"debug_panel":KEY_F1,"look_around":KEY_C,"look_side":KEY_V}
	for action: String in bindings:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		var physical := InputEventKey.new()
		physical.physical_keycode = bindings[action]
		InputMap.action_add_event(action,physical)
		var logical := InputEventKey.new()
		logical.keycode = bindings[action]
		InputMap.action_add_event(action,logical)
