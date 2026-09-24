extends "res://npc/BaseNPC.gd"
signal finish_requested
var greeted := false
var greeting_remaining := 0.0

func _process(delta: float) -> void:
	super._process(delta)
	if not GameState.can_move():
		return
	if greeting_remaining > 0:
		greeting_remaining -= delta
		if greeting_remaining <= 0:
			say("在这里！等你一起进去。")
	elif not greeted and nearby(14):
		greeted = true
		notice(true)
		greeting_remaining = 0.4

func _init() -> void:
	display_name = "朋友"
	actor_id = "friend_01"
	outfit = Color("78a28c")

func feedback() -> String:
	var lines: Array[String] = []
	lines.append("你总算到了，至少这次还知道回我消息。" if GameState.get_flag("responded_to_friend") else "你终于出现了，我还以为你失踪了。")
	if GameState.get_flag("helped_student"):
		lines.append("你说路上还帮人拍照了？难怪这么久。")
	if GameState.get_flag("teacher_warned"):
		lines.append("你说还被老师提醒看路了？那先把手机收好吧。")
	lines.append("时间刚好，我们进去吧。" if GameState.get_flag("arrived_on_time") else "已经开始了，我们轻一点进去吧。")
	return "\n\n".join(lines)

func interact() -> void:
	if not GameState.get_flag("reached_high_table"):
		var arrival: float = GameState.get_value("current_game_time")
		GameState.set_flag("reached_high_table", true)
		GameState.set_value("arrival_time", arrival)
		GameState.set_flag("arrived_on_time", arrival < GameState.DEADLINE)
		EventBus.emit_event("HIGH_TABLE_REACHED", actor_id, {"arrival_time":arrival, "on_time":GameState.get_flag("arrived_on_time")})
	dialogue_requested.emit(display_name, "（你和朋友简单说了说路上的经历。）\n\n" + feedback(), [{"text":"一起进入高桌晚宴", "action":func(): finish_requested.emit()}])
