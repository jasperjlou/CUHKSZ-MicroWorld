extends RefCounted
## World geometry routing adapter; Agent actions and physical locomotion stay unchanged.
const Junction := preload("res://world/JunctionLayout.gd")
var graph := AStar3D.new()
var edges: Array = []
var ids: Dictionary = {}

func _init(legacy_points: Array[Vector3]) -> void:
	for i in legacy_points.size():
		graph.add_point(i,legacy_points[i])
		if i > 0:
			connect_points(i-1,i)
	ids.UNKNOWN_CONNECTOR = 0
	for node: Dictionary in Junction.definition().nodes:
		if node.id == "UNKNOWN_CONNECTOR":
			continue
		var index := graph.get_point_count()
		ids[node.id] = index
		graph.add_point(index,Junction.point(node.id))
	for segment: Dictionary in Junction.definition().segments:
		for i in range(segment.nodes.size()-1):
			connect_points(ids[segment.nodes[i]],ids[segment.nodes[i+1]])

func connect_points(a: int,b: int) -> void:
	graph.connect_points(a,b)
	edges.append([a,b])

func route(start: Vector3, destination: Vector3) -> Array[Vector3]:
	# First rejoin the nearest edge, then follow graph edges, never cut across grass.
	var nearest := INF
	var projection := start
	var pair: Array = []
	for edge: Array in edges:
		var a := graph.get_point_position(edge[0])
		var b := graph.get_point_position(edge[1])
		var q := a.lerp(b,clampf((start-a).dot(b-a)/(b-a).length_squared(),0,1))
		if start.distance_to(q) < nearest:
			nearest = start.distance_to(q)
			projection = q
			pair = edge
	var target := graph.get_closest_point(destination)
	var best := INF
	var selected: PackedVector3Array = []
	for endpoint: int in pair:
		var path := graph.get_point_path(endpoint,target)
		var cost := projection.distance_to(path[0])
		for i in range(path.size()-1):
			cost += path[i].distance_to(path[i+1])
		if cost < best:
			best = cost
			selected = path
	var result: Array[Vector3] = [projection]
	result.append_array(selected)
	return result

func distance(start: Vector3, destination: Vector3) -> float:
	var total := 0.0
	var previous := start
	for waypoint: Vector3 in route(start,destination):
		total += previous.distance_to(waypoint)
		previous = waypoint
	return total
