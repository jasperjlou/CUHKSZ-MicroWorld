extends RefCounted
# Traversal anchors are shared with AgentEnvironment; future regions are plans only.
const TARGETS := {
	"start_plaza":Vector3(0, 0, 49.6),
	"main_walkway":Vector3(0, 0, 27),
	"photo_spot":Vector3(8.64, 0, -32.2),
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
	if pos.x > 5 and pos.z < -29 and pos.z > -42: return "photo_spot"
	if pos.x < -10: return "small_garden"
	return "main_walkway"

# Public geographical knowledge is deliberately separate from executable TARGETS.
const KNOWN_REGIONS := [
 {"region_id":"upper_campus", "display_name":"上园", "enabled":true},
 {"region_id":"high_table_area", "display_name":"高桌晚宴区域", "enabled":true},
 {"region_id":"middle_campus", "display_name":"中园", "enabled":false},
 {"region_id":"fairy_lake", "display_name":"神仙湖", "enabled":false},
 {"region_id":"lower_campus", "display_name":"下园", "enabled":false}
]
const CONNECTORS := [
 {"connector_id":"upper_to_high_table", "from_region":"upper_campus", "to_region":"high_table_area", "approximate_distance":100.0, "transport_modes":["walk"], "enabled":true},
 {"connector_id":"upper_to_middle", "from_region":"upper_campus", "to_region":"middle_campus", "approximate_distance":null, "transport_modes":["walk"], "enabled":false},
 {"connector_id":"middle_to_lake", "from_region":"middle_campus", "to_region":"fairy_lake", "approximate_distance":null, "transport_modes":["walk"], "enabled":false},
 {"connector_id":"lake_to_lower", "from_region":"fairy_lake", "to_region":"lower_campus", "approximate_distance":null, "transport_modes":["walk"], "enabled":false}
]
const BUS_STOP := {"id":"upper_shuttle_reserve", "display_name":"校园接驳候车点", "region":"upper_campus", "position":[15,0,-25], "waiting_area":{"center":[15,0.12,-23.6],"size":[3,2]}, "boarding_point":[17,0,-26], "active":false}

static func region_at(pos: Vector3) -> String:
	return "high_table_area" if pos.z < -29 else "upper_campus"
