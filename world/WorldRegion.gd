extends RefCounted
# Traversal anchors are shared with AgentEnvironment; future regions are plans only.
const TARGETS := {
	"start_plaza":Vector3(0, 0, 49.6),
	"main_walkway":Vector3(0, 0, 27),
	"photo_spot":Vector3(8.64, 0, -15.6),
	"high_table":Vector3(0, 0, -48.2)
}
const REGIONS := {
	"high_table_slice": {"region_id":"high_table_slice", "display_name":"高桌晚宴沿途", "connections":[], "navigation_entry_points":["start_plaza"], "semantic_tags":["campus", "evening", "playable"]},
	"start_plaza": {"region_id":"start_plaza", "display_name":"庭院", "connections":["main_walkway"], "navigation_entry_points":["start_plaza"], "semantic_tags":["courtyard", "start"]},
	"main_walkway": {"region_id":"main_walkway", "display_name":"校园连廊", "connections":["start_plaza", "small_garden", "photo_spot", "high_table"], "navigation_entry_points":["main_walkway"], "semantic_tags":["colonnade", "teacher_encounter"]},
	"small_garden": {"region_id":"small_garden", "display_name":"林荫小径", "connections":["main_walkway"], "navigation_entry_points":[], "semantic_tags":["garden", "human_exploration"]},
	"photo_spot": {"region_id":"photo_spot", "display_name":"赴宴合影区", "connections":["main_walkway"], "navigation_entry_points":["photo_spot"], "semantic_tags":["photo", "formal_event"]},
	"high_table": {"region_id":"high_table", "display_name":"高桌晚宴门厅", "connections":["main_walkway"], "navigation_entry_points":["high_table"], "semantic_tags":["foyer", "arrival", "dinner"]}
}

static func at_position(pos: Vector3) -> String:
	if pos.z > 40: return "start_plaza"
	if pos.z < -44: return "high_table"
	if pos.x > 5 and pos.z < -10 and pos.z > -28: return "photo_spot"
	if pos.x < -10: return "small_garden"
	return "main_walkway"
