extends RefCounted
const Layout := preload("res://world/JunctionLayout.gd")
const Kit := preload("res://world/MeshKit.gd")
const Lamp := preload("res://assets/campus/SingleArmLamp.tscn")

static func floor_disc(parent: Node3D, p: Vector3, radius: float, color: Color, solid: bool) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.12
	mesh.radial_segments = 32
	var instance := Kit.mesh(parent,mesh,p-Vector3.UP*0.06,color)
	if solid:
		instance.create_trimesh_collision()

static func junction_patch(parent: Node3D,p: Vector3,radius: float,color: Color,solid: bool,links: Array) -> void:
	# Follow incoming slopes instead of introducing a raised flat cylinder edge.
	var vertices: Array[Vector3] = []
	for i in range(32):
		var vertex := p+Vector3(cos(TAU*i/32)*radius,0,sin(TAU*i/32)*radius)
		var best := INF
		for link: Array in links:
			var a: Vector3 = link[0]
			var b: Vector3 = link[1]
			if Vector2(p.x-a.x,p.z-a.z).length() > 0.1 and Vector2(p.x-b.x,p.z-b.z).length() > 0.1:
				continue
			var delta := Vector3(b.x-a.x,0,b.z-a.z)
			var t := clampf(Vector3(vertex.x-a.x,0,vertex.z-a.z).dot(delta)/delta.length_squared(),0,1)
			var projection := a.lerp(b,t)
			var distance := Vector2(vertex.x-projection.x,vertex.z-projection.z).length()
			if distance < best:
				best = distance
				vertex.y = projection.y+(0 if solid else 0.018)
		vertices.append(vertex)
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(vertices.size()):
		for vertex: Vector3 in [p,vertices[i],vertices[(i+1)%vertices.size()]]:
			surface.add_vertex(vertex)
	surface.generate_normals()
	var instance := Kit.mesh(parent,surface.commit(),Vector3.ZERO,color)
	if solid:
		instance.create_trimesh_collision()

static func build(builder: Node3D) -> void:
	var root := Node3D.new()
	root.name = "ReplaceableJunctionWorld"
	root.set_meta("confidence","inferred")
	root.set_meta("replaceable",true)
	builder.add_child(root)
	for record: Dictionary in Layout.objects():
		var node := Node3D.new()
		node.name = record.id
		node.position = Vector3(record.position[0],record.position[1],record.position[2])
		node.set_meta("semantic",record.duplicate(true))
		node.add_to_group("lake_semantics")
		root.add_child(node)
		builder.semantic_nodes[record.id] = node
	var links: Array = []
	for segment: Dictionary in Layout.definition().segments:
		var first_beam := builder.get_child_count()
		var section := Node3D.new()
		section.name = segment.id
		section.set_meta("confidence",segment.confidence)
		section.set_meta("inference_basis",segment.inference_basis.duplicate())
		section.set_meta("replaceable",true)
		root.add_child(section)
		for i in range(segment.nodes.size()-1):
			var a := Layout.point(segment.nodes[i])
			var b := Layout.point(segment.nodes[i+1])
			var forward := (b-a).normalized()
			var right := Vector3(forward.z,0,-forward.x).normalized()
			var ra := right
			var width := 7.0
			if segment.nodes[i] == "UNKNOWN_CONNECTOR":
				ra = preload("res://world/ForestConnectorLayout.gd").right_at(3)
				width = 12.0
			builder.strip(a-ra*width,a+ra*width,b+right*7,b-right*7,Color("8a9d77"),true,section)
			builder.strip(a-ra*(width-3)+Vector3.UP*0.012,a+ra*(width-3)+Vector3.UP*0.012,b+right*4+Vector3.UP*0.012,b-right*4+Vector3.UP*0.012,Color("b3b9ad"),false,section)
			links.append([a,b,ra,right,width])
			for side: float in [-1,1]:
				builder.beam(a+ra*side*(width-3)+Vector3.UP*0.025,b+right*side*4+Vector3.UP*0.025,0.12,0.05,Color("d2cfba"))
			var lamp := Lamp.instantiate()
			lamp.position = a.lerp(b,0.52)-right*5.3
			section.add_child(lamp)
			# Keep the final approach and its reverse camera clear of the gate.
			if segment.nodes[i+1] != "LingCollege_Approach":
				Kit.tree(section,a.lerp(b,0.7)+right*9,5.0)
			# Low retaining wall follows the outer grass edge, not a tall opaque facade.
			builder.beam(a.lerp(b,0.25)+right*8.4-Vector3.UP*0.6,a.lerp(b,0.75)+right*8.4-Vector3.UP*0.6,0.45,1.1,Color("969f8b"))
		stamp(section,segment)
		stamp_added(builder,first_beam,segment)
	for node: Dictionary in Layout.definition().nodes:
		if node.id == "UNKNOWN_CONNECTOR":
			continue
		var p := Layout.point(node.id)
		var first_patch := root.get_child_count()
		var first_rim := builder.get_child_count()
		junction_patch(root,p,7,Color("8a9d77"),true,links)
		junction_patch(root,p+Vector3.UP*0.018,4.9,Color("b3b9ad"),false,links)
		# Keep only exposed parts of a junction rim. Openings face connected paths.
		for i in range(32):
			var theta := TAU*(i+0.5)/32
			var mid := p+Vector3(cos(theta)*6.8,0.45,sin(theta)*6.8)
			if inside_link(mid,links):
				continue
			var a := p+Vector3(cos(TAU*i/32)*6.9,0.4,sin(TAU*i/32)*6.9)
			var b := p+Vector3(cos(TAU*(i+1)/32)*6.9,0.4,sin(TAU*(i+1)/32)*6.9)
			builder.beam(a,b,0.45,0.8,Color("758b64"),true)
		stamp_added(root,first_patch,node)
		stamp_added(builder,first_rim,node)
	# Exposed corridor edges are clipped against all node plazas and other corridors.
	for link: Array in links:
		var a: Vector3 = link[0]
		var b: Vector3 = link[1]
		var first_edge := builder.get_child_count()
		var count := int(ceil(a.distance_to(b)))
		for side: float in [-1,1]:
			for i in range(count):
				var t := (i+0.5)/count
				var mid := a.lerp(b,t)+(link[2] as Vector3).lerp(link[3],t)*side*lerpf(link[4],7,t)
				var covered := false
				for node: Dictionary in Layout.definition().nodes:
					if node.id != "UNKNOWN_CONNECTOR" and Vector2(mid.x-Layout.point(node.id).x,mid.z-Layout.point(node.id).z).length() < 7.25:
						covered = true
				if covered or inside_link(mid,links,link):
					continue
				var p := a.lerp(b,float(i)/count)+(link[2] as Vector3).lerp(link[3],float(i)/count)*side*lerpf(link[4],7,float(i)/count)
				var q := a.lerp(b,float(i+1)/count)+(link[2] as Vector3).lerp(link[3],float(i+1)/count)*side*lerpf(link[4],7,float(i+1)/count)
				builder.beam(p+Vector3.UP*0.4,q+Vector3.UP*0.4,0.45,0.8,Color("758b64"),true)
		stamp_added(builder,first_edge,Layout.section(a.lerp(b,0.5)))
	var round_root := root.get_child_count()
	var round_beams := builder.get_child_count()
	build_roundabout(builder,root)
	var ring_record := {"confidence":"placeholder","inference_basis":["Campus Guide junction topology; vehicle ring dimensions and placement are not surveyed."]}
	stamp_added(root,round_root,ring_record)
	stamp_added(builder,round_beams,ring_record)
	var first_sign := root.get_child_count()
	build_wayfinding(builder,root)
	for child: Node in root.get_children().slice(first_sign):
		stamp(child,Layout.section((child as Node3D).position))

static func stamp(node: Node, record: Dictionary) -> void:
	node.set_meta("confidence",record.get("confidence","placeholder"))
	node.set_meta("inference_basis",record.get("inference_basis",["Adjacent path layout and campus guide; not surveyed."]).duplicate())
	node.set_meta("replaceable",true)
	for child: Node in node.get_children():
		stamp(child,record)

static func stamp_added(parent: Node, first: int, record: Dictionary) -> void:
	for child: Node in parent.get_children().slice(first):
		stamp(child,record)

static func inside_link(p: Vector3,links: Array,skip: Array = []) -> bool:
	for link: Array in links:
		if link == skip:
			continue
		var a: Vector3 = link[0]
		var b: Vector3 = link[1]
		var flat := Vector3(p.x,a.y,p.z)
		var delta := Vector3(b.x-a.x,0,b.z-a.z)
		var t := (flat-a).dot(delta)/delta.length_squared()
		if t <= 0 or t >= 1:
			continue
		if flat.distance_to(a+delta*t) < lerpf(link[4],7,t)-0.08:
			return true
	return false

static func build_roundabout(builder: Node3D,root: Node3D) -> void:
	var center := Vector3(50,2.95,158)
	floor_disc(root,center,17,Color("687878"),false)
	floor_disc(root,center+Vector3.UP*0.1,10.8,Color("bebead"),false)
	floor_disc(root,center+Vector3.UP*0.17,10,Color("718a5d"),false)
	for i in range(5):
		var angle := TAU*i/5
		Kit.tree(root,center+Vector3(cos(angle)*4,0.2,sin(angle)*4),4.8)
	for i in range(24):
		var a := center+Vector3(cos(TAU*i/24)*14,0.025,sin(TAU*i/24)*14)
		var b := center+Vector3(cos(TAU*(i+0.55)/24)*14,0.025,sin(TAU*(i+0.55)/24)*14)
		builder.beam(a,b,0.12,0.02,Color("dddac4"))

static func build_wayfinding(builder: Node3D,root: Node3D) -> void:
	var sign := Layout.point("FirstJunction")+Vector3(-4.6,0,0)
	Kit.cylinder(root,sign+Vector3.UP*1.8,0.11,3.6,Color("546a5b"))
	Kit.box(root,sign+Vector3.UP*3.2,Vector3(4.7,1.8,0.18),Color("375f51"))
	double_sided_text(builder,root,"上园 ↗　道扬书院 ↖\n下园 ←　神仙湖 ↓\n方向按现有资料推定","上园 ↖　道扬书院 ↗\n下园 →　神仙湖 ↓\n方向按现有资料推定",sign+Vector3(0,3.25,0),0.12,21)
	for id: String in ["UpperBranch_End","LowerBranch_End","OtherBranch_End"]:
		var p := Layout.point(id)+Vector3(3.7,0,0)
		Kit.cylinder(root,p+Vector3.UP*1.1,0.07,2.2,Color("617461"))
		Kit.box(root,p+Vector3.UP*2.05,Vector3(3.2,1.1,0.12),Color("466756"))
		double_sided_text(builder,root,"本段步道到这里\n可原路返回岔路","本段步道到这里\n可原路返回岔路",p+Vector3(0,2.05,0),0.08,23)
	# A modest, original gate silhouette; this is an inferred approach, not the college interior.
	var gate := Layout.point("LingCollege_Approach")+Vector3(0,0,2.5)
	for x: float in [-3,3]:
		Kit.box(root,gate+Vector3(x,2.6,0),Vector3(0.6,5.2,0.7),Color("999d8c"),true)
	Kit.box(root,gate+Vector3.UP*4.8,Vector3(7.6,1.1,0.9),Color("949887"))
	double_sided_text(builder,root,"道扬书院方向","道扬书院方向",gate+Vector3(0,4.8,0),0.48,29)
	Kit.label(root,"入口位置按资料推定\n本轮暂到门前",gate+Vector3(0,1.6,0),20)

static func double_sided_text(builder: Node3D,parent: Node3D,front: String,back: String,p: Vector3,depth: float,size: int) -> void:
	builder.physical_text(parent,front,p+Vector3(0,0,depth),size)
	builder.physical_text(parent,back,p-Vector3(0,0,depth),size)
	(parent.get_child(-1) as Label3D).rotation.y = PI
