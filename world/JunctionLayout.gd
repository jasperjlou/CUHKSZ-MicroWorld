extends RefCounted
const Lake := preload("res://world/FairyLakeLayout.gd")
static var data: Dictionary = {}

static func definition() -> Dictionary:
	if data.is_empty():
		data = JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/junction_world.json"))
	return data

static func point(id: String) -> Vector3:
	for node: Dictionary in definition().nodes:
		if node.id == id:
			return Vector3(node.p[0],node.p[1],node.p[2])
	return Vector3.ZERO

static func objects() -> Array:
	var result: Array = []
	for node: Dictionary in definition().nodes:
		if node.id == "UNKNOWN_CONNECTOR":
			continue # Backwards-compatible ID is still owned by the original connector.
		var record := Lake.object(node.id,node.name_zh,"Junction" if node.id == "FirstJunction" else "Path",point(node.id),true,true,false,true,true,["inferred_world","replaceable"],node.confidence)
		record.confidence = node.confidence
		record.zone = node.zone
		record.connector = true
		record.replaceable = true
		record.inference_basis = []
		for segment: Dictionary in definition().segments:
			if node.id in segment.nodes:
				record.inference_basis.append_array(segment.inference_basis)
		record.evidence.position = node.confidence
		record.evidence.topology = node.confidence
		record.evidence.geographic_registration = "not_surveyed"
		result.append(record)
	var road := Lake.object("Junction_VehicleRoad","环岛车行道","Road",Vector3(50,3.0,158),false,false,true,true,false,["vehicle_only","replaceable"],"placeholder")
	road.zone = "ZONE_JUNCTION"
	road.replaceable = true
	road.inference_basis = ["环岛候选全景有车道；圆形岛与车道尺寸为占位设计"]
	result.append(road)
	return result

static func section(p: Vector3) -> Dictionary:
	var closest := INF
	var result: Dictionary = {}
	for segment: Dictionary in definition().segments:
		for i in range(segment.nodes.size()-1):
			var a := point(segment.nodes[i])
			var b := point(segment.nodes[i+1])
			var projection := a.lerp(b,clampf((p-a).dot(b-a)/(b-a).length_squared(),0,1))
			var distance := p.distance_to(projection)
			if distance < closest:
				closest = distance
				result = segment
	return result.duplicate(true)
