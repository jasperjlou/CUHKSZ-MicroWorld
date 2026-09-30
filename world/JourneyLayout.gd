extends RefCounted
const Junction := preload("res://world/JunctionLayout.gd")
const Lake := preload("res://world/FairyLakeLayout.gd")

static func definition() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/cross_campus_journey.json"))

static func objects() -> Array:
	var result: Array = []
	for anchor: Dictionary in definition().anchors:
		var record := Lake.object(anchor.id,anchor.name_zh,"Campus_Area",Junction.point(anchor.alias),true,true,false,true,true,["journey_anchor","bounded_slice"],anchor.confidence)
		record.merge(anchor,true)
		record.evidence.geographic_registration = "not_surveyed"
		result.append(record)
	return result

static func zone_at(p: Vector3) -> String:
	for anchor: Dictionary in definition().anchors:
		if p.distance_to(Junction.point(anchor.alias)) < 7:
			return anchor.zone
	return ""
