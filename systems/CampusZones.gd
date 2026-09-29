extends RefCounted
const Junction := preload("res://world/JunctionLayout.gd")
## Region identity is separate from whether a real campus connector has been verified.
static func definitions() -> Array:
	return [
		{"id":"ZONE_MIDDLE_ROAD","name_zh":"湖口连接步道","active":true,"confidence":"inferred"},
		{"id":"ZONE_JUNCTION","name_zh":"第一岔路","active":true,"confidence":"placeholder"},
		{"id":"ZONE_UPPER_BRANCH","name_zh":"上园方向支路","active":true,"confidence":"inferred"},
		{"id":"ZONE_COLLEGE_BRANCH","name_zh":"道扬书院方向支路","active":true,"confidence":"inferred"},
		{"id":"ZONE_LOWER_BRANCH","name_zh":"下园方向支路","active":true,"confidence":"inferred"},
		{"id":"ZONE_OTHER_BRANCH","name_zh":"其他区域支路","active":true,"confidence":"placeholder"},
		{"id":"ZONE_CONNECTOR_UNKNOWN","name_zh":"林缘路侧过渡区","active":true,"confidence":"inferred","connection":"UNKNOWN_CONNECTOR","real_connection_verified":false},
		{"id":"ZONE_UPPER_CAMPUS","name_zh":"上园（尚未接入）","active":false,"confidence":"placeholder"},
		{"id":"ZONE_UPPER_CONNECTOR","name_zh":"神仙湖入口过渡区","active":true,"confidence":"inferred","real_upper_connection_verified":false},
		{"id":"ZONE_FAIRY_LAKE","name_zh":"神仙湖步道","active":true,"confidence":"inferred"},
		{"id":"ZONE_SHUTTLE_STOP","name_zh":"原型候车点","active":true,"confidence":"placeholder"},
		{"id":"ZONE_LOWER_CONNECTOR","name_zh":"下园方向占位出口","active":true,"confidence":"placeholder","real_lower_connection_verified":false},
		{"id":"ZONE_LOWER_CAMPUS","name_zh":"下园（尚未接入）","active":false,"confidence":"placeholder"}]

static func locate(position: Vector3, near_stop: bool, riding: bool) -> String:
	if riding:
		return "IN_TRANSPORT"
	if near_stop:
		return "ZONE_SHUTTLE_STOP"
	if position.z > 112:
		var closest := INF
		var zone := "ZONE_MIDDLE_ROAD"
		for node: Dictionary in Junction.definition().nodes:
			var distance := position.distance_to(Junction.point(node.id))
			if distance < closest:
				closest = distance
				zone = node.zone
		return zone
	if position.z > 80:
		return "ZONE_CONNECTOR_UNKNOWN"
	if position.z > 44:
		return "ZONE_UPPER_CONNECTOR"
	if position.z < -35:
		return "ZONE_LOWER_CONNECTOR"
	return "ZONE_FAIRY_LAKE"
