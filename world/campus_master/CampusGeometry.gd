extends RefCounted
## Independent authoring frame; does not modify any RC1 layout or navigation.
const Kit := preload("res://world/MeshKit.gd")
static var master: Dictionary = {}
static var paths: Dictionary = {}
static var height_cache: Dictionary = {}

static func load_data() -> void:
	if not master.is_empty(): return
	master = JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/campus_masterplan.json"))
	paths = JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/campus_paths.json"))

static func vec(v: Array) -> Vector3:
	return Vector3(float(v[0]),float(v[1]),float(v[2]))

static func shore() -> PackedVector2Array:
	var result := PackedVector2Array()
	for p: Array in master.lake.shoreline: result.append(Vector2(p[0],p[1]))
	return result

static func raw_height(x: float,z: float) -> float:
	var key := Vector2(x,z)
	if height_cache.has(key): return height_cache[key]
	var t := clampf((z+80.0)/650.0,0,1)
	var y := 8.0+46.0*(1.0-t*t*(3.0-2.0*t))
	if x < 285 and z < 270 and z > -180:
		var polygon := shore()
		var p := Vector2(x,z)
		var distance := INF
		for i in range(polygon.size()):
			distance = minf(distance,p.distance_to(Geometry2D.get_closest_point_to_segment(p,polygon[i],polygon[(i+1)%polygon.size()])))
		if Geometry2D.is_point_in_polygon(p,polygon):
			y = 20.5
		else:
			y = lerpf(24.5,y,smoothstep(0,110,distance))
	# One shared ground surface meets the authored building/platform datums.
	for o: Dictionary in master.objects:
		if o.category not in ["building","track","court","plaza","garden"]: continue
		var dx := absf(x-o.center[0])-o.footprint_width/2.0
		var dz := absf(z-o.center[2])-o.footprint_depth/2.0
		var edge := maxf(dx,dz)
		if edge < 12:
			y = lerpf(float(o.elevation),y,smoothstep(0,12,maxf(0,edge)))
	height_cache[key] = y
	return y

static func height_at(x: float,z: float) -> float:
	# Same grid diagonal as the rendered/collision terrain: no independent floor formula.
	var step := float(master.terrain.grid_step)
	var gx := floorf((x-master.terrain.x_min)/step)*step+master.terrain.x_min
	var gz := floorf((z-master.terrain.z_min)/step)*step+master.terrain.z_min
	var tx := (x-gx)/step
	var tz := (z-gz)/step
	var a := raw_height(gx,gz)
	var c := raw_height(gx+step,gz+step)
	if tx >= tz:
		return a*(1-tx)+raw_height(gx+step,gz)*(tx-tz)+c*tz
	return a*(1-tz)+c*tx+raw_height(gx,gz+step)*(tz-tx)

static func point(id: String) -> Vector3:
	for n: Dictionary in paths.nodes:
		if n.id == id:
			return Vector3(n.position[0],height_at(n.position[0],n.position[2])+.22,n.position[2])
	return Vector3.ZERO

static func provenance(node: Node, record: Dictionary) -> void:
	node.set_meta("spatial_record",record.duplicate(true))
	node.set_meta("confidence",record.get("confidence","inferred"))
	node.set_meta("replaceable",true)

static func surface(parent: Node3D, verts: PackedVector3Array, color: Color, solid: bool = false) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for v: Vector3 in verts: st.add_vertex(v)
	st.generate_normals()
	var node := Kit.mesh(parent,st.commit(),Vector3.ZERO,color)
	if solid: node.create_trimesh_collision()
	return node

static func quad(a: Vector3,b: Vector3,c: Vector3,d: Vector3) -> PackedVector3Array:
	# Godot front-face winding; terrain is visible and collidable from above.
	return PackedVector3Array([a,b,c,a,c,d])

static func terrain(parent: Node3D) -> void:
	var verts := PackedVector3Array()
	var step := int(master.terrain.grid_step)
	for z in range(int(master.terrain.z_min),int(master.terrain.z_max),step):
		for x in range(int(master.terrain.x_min),int(master.terrain.x_max),step):
			verts.append_array(quad(Vector3(x,raw_height(x,z),z),Vector3(x+step,raw_height(x+step,z),z),Vector3(x+step,raw_height(x+step,z+step),z+step),Vector3(x,raw_height(x,z+step),z+step)))
	var node := surface(parent,verts,Color("93a77a"),true)
	node.name = "EstimatedMacroTerrain"
	provenance(node,master.terrain)

static func lake(parent: Node3D) -> void:
	var polygon := shore()
	var indices := Geometry2D.triangulate_polygon(polygon)
	var vertices := PackedVector3Array()
	for i in range(0,indices.size(),3):
		for j in [0,1,2]:
			var p := polygon[indices[i+j]]
			vertices.append(Vector3(p.x,24,p.y))
	var water := surface(parent,vertices,Color("6c9da1"))
	water.name = "ApproximateLakePolygon"
	# Triangulate_polygon uses 2D CCW, matching our XZ front faces.
	provenance(water,master.lake)
	var banks := PackedVector3Array()
	for i in range(polygon.size()):
		var a := polygon[i]
		var b := polygon[(i+1)%polygon.size()]
		var right := Vector2(b.y-a.y,a.x-b.x).normalized()*3
		banks.append_array(quad(Vector3(a.x,24.1,a.y),Vector3(b.x,24.1,b.y),Vector3(b.x+right.x,24.7,b.y+right.y),Vector3(a.x+right.x,24.7,a.y+right.y)))
	surface(parent,banks,Color("c3c4a0"))

static func strip(parent: Node3D, points: Array[Vector3],width: float,color: Color,solid: bool = true) -> MeshInstance3D:
	var dense: Array[Vector3] = []
	for i in range(points.size()-1):
		var count := maxi(1,ceili(points[i].distance_to(points[i+1])/4.0))
		for j in range(count): dense.append(points[i].lerp(points[i+1],j/float(count)))
	dense.append(points[-1])
	var left: Array[Vector3] = []
	var right: Array[Vector3] = []
	for i in range(dense.size()):
		var tangent := dense[mini(i+1,dense.size()-1)]-dense[maxi(i-1,0)]
		var r := Vector3(tangent.z,0,-tangent.x).normalized()*width/2
		var a := dense[i]-r
		var b := dense[i]+r
		a.y = height_at(a.x,a.z)+.16
		b.y = height_at(b.x,b.z)+.16
		left.append(a);right.append(b)
	var verts := PackedVector3Array()
	for i in range(dense.size()-1): verts.append_array(quad(left[i],right[i],right[i+1],left[i+1]))
	return surface(parent,verts,color,solid)

static func roads(parent: Node3D) -> void:
	for r: Dictionary in master.roads+paths.paths:
		var pts: Array[Vector3] = []
		for id: String in r.nodes: pts.append(point(id))
		var vehicle := r.category == "vehicle"
		var node := strip(parent,pts,r.width,Color("777f7b") if vehicle else Color("d7cdb4"))
		node.name = r.id
		provenance(node,r)

static func bounds(parent: Node3D) -> void:
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_LINES)
	for i in range(master.bounds.size()):
		var a: Array = master.bounds[i]
		var b: Array = master.bounds[(i+1)%master.bounds.size()]
		st.add_vertex(Vector3(a[0],height_at(a[0],a[1])+1,a[1]))
		st.add_vertex(Vector3(b[0],height_at(b[0],b[1])+1,b[1]))
	var node := Kit.mesh(parent,st.commit(),Vector3.ZERO,Color("e8d1a0"))
	node.name = "NonPhysicalCampusBounds"
