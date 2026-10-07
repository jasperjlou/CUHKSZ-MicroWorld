extends RefCounted
const G := preload("res://world/campus_exterior/ExteriorGeometry.gd")
var graph := AStar3D.new()
var locations: Dictionary = {}
var data: Dictionary
func _init() -> void:
	data=JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/campus_locations_v6.json"))
	var interiors: Array=JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/campus_interiors.json"))
	for i in data.points.size():
		var p:=G.vec(data.points[i]);var indoors:=false
		for d: Dictionary in interiors:
			for o: Dictionary in G.master.objects:
				if o.id==d.building_id and absf(p.x-o.center[0])<=d.width/2 and absf(p.z-o.center[2]-d.center_local[2])<=d.depth/2:indoors=true;break
		if not indoors:p.y=G.height_at(p.x,p.z)
		graph.add_point(i,p)
	for edge: Array in data.edges:graph.connect_points(edge[0],edge[1],true)
	for record: Dictionary in data.locations:locations[record.id]=record
func anchor(id: String) -> Vector3:
	return graph.get_point_position(locations[id].world_anchor)
func plan(position: Vector3,id: String) -> PackedVector3Array:
	if not locations.has(id):return PackedVector3Array()
	var from:=graph.get_closest_point(position)
	return graph.get_point_path(from,locations[id].world_anchor)
func at(position: Vector3) -> String:
	var closest:="";var distance:=INF
	for id: String in locations:
		var d:=position.distance_to(anchor(id))
		if d<distance or (is_equal_approx(d,distance) and locations[id].type=="room"):distance=d;closest=id
	return closest if distance<1.4 else ""
func public_catalog() -> Array:
	var result: Array=[]
	for r: Dictionary in locations.values():result.append({"id":r.id,"name":r.display_name_zh,"region":r.region,"building_id":r.building_id,"type":r.type})
	return result
