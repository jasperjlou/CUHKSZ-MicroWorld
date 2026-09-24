extends RefCounted
const FONT = preload("res://assets/fonts/ChineseUI.tres")
const LOCATIONS := {"start_plaza":"入口广场", "main_walkway":"校园连廊", "photo_spot":"合影花园", "small_garden":"林荫小径", "high_table":"高桌晚宴入口"}
const EVENTS := {
	"TEACHER_PASSED":"经过老师身边", "LLM_PARSE_ERROR":"模型输出格式错误", "LLM_INVALID_ACTION":"模型选择了不可用动作", "LLM_PROVIDER_ERROR":"模型服务调用失败", "BENCHMARK_FINISHED":"评测本局结束",
	"AGENT_ACTION":"程序执行动作", "AGENT_INVALID_ACTION":"程序动作无效", "AGENT_EPISODE_TRUNCATED":"程序到达步数上限",
	"GAME_STARTED":"开始赴宴", "PHONE_OPENED":"拿出手机", "PHONE_CLOSED":"收起手机",
	"FRIEND_MESSAGE_RECEIVED":"收到朋友消息", "FRIEND_REPLIED":"回复朋友", "FRIEND_IGNORED":"稍后回复朋友",
	"TEACHER_SAW_PHONE":"老师看到边走边看手机", "TEACHER_WARNED_PLAYER":"老师第一次提醒",
	"TEACHER_SECOND_WARNING":"老师第二次提醒", "TEACHER_ACKNOWLEDGED":"老师回应收起手机",
	"PHOTO_REQUESTED":"同学请求拍照", "PHOTO_ACCEPTED":"答应帮忙", "PHOTO_COMPLETED":"完成拍照",
	"PHOTO_DECLINED":"婉拒拍照", "HIGH_TABLE_REACHED":"到达晚宴入口", "GAME_FINISHED":"本局结束",
	"VERIFIER_RESULT":"任务验证完成", "TIME_COST":"拍照花费时间", "LOCATION_CHANGED":"进入新地点",
	"DEADLINE_PASSED":"晚宴已开始", "PAUSED":"暂停游戏", "RESUMED":"继续游戏",
	"RUN_ABORTED":"提前结束本局", "TASK_SELECTED":"选择赴宴任务"
	,"INTERACTION_STARTED":"人物转身回应", "TEACHER_NOTICED_PLAYER":"老师注意到你，转身示意", "PHOTO_SHUTTER":"按下快门"
}

static func event_name(id: String) -> String:
	return EVENTS.get(id, "世界状态更新")

static func yes_no(value: bool) -> String:
	return "是" if value else "否"

static func story_summary(state: Dictionary) -> String:
	var lines: Array[String] = []
	var helped := bool(state.get("helped_student", false))
	if not state.get("reached_high_table", false):
		lines.append("你帮同学留下了合影，不过这次没能走到晚宴门口。" if helped else "校园里多停留了一会儿，这次没能走到晚宴门口。")
	elif state.get("arrived_on_time", false):
		lines.append("你顺路帮同学拍了张合影，也准时赶到了高桌晚宴。" if helped else "你沿着连廊来到晚宴门口，朋友正等着你，时间刚刚好。")
	else:
		lines.append("你帮同学拍好了合影，到晚宴门口时已经过了七点。" if helped else "你走到晚宴门口时已经过了七点，朋友仍在等你。")
	if state.get("teacher_warned_twice", false):
		lines.append("路上又拿出了手机，老师先后提醒了你两次。")
	elif state.get("teacher_warned", false):
		lines.append("路上边走边看手机，被老师提醒了一次。")
	else:
		lines.append("这一路没有因为看手机被老师提醒。")
	lines.append("你提前回了消息，朋友知道你正在路上。" if state.get("responded_to_friend", false) else "朋友的消息一直没回，下次记得打个招呼。")
	return "".join(lines)
