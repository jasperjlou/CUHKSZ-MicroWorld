extends Node3D
const Kit := preload("res://world/MeshKit.gd")
const Layout := preload("res://world/FairyLakeLayout.gd")
var semantic_nodes: Dictionary = {}

func _ready() -> void:
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("b1c8c4")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("d7e3de")
	settings.ambient_light_energy = 0.42
	environment.environment = settings
	add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-46,-32,0)
	sun.light_energy = 0.46
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 130
	add_child(sun)
	for record: Dictionary in Layout.objects():
		var node := Node3D.new()
		node.name = record.id + "__" + record.evidence.position
		node.position = Layout.position_of(record)
		node.set_meta("semantic",record.duplicate(true))
		node.add_to_group("lake_semantics")
		add_child(node)
		semantic_nodes[record.id] = node
	_build_land()
	_build_water()
	_build_landmarks()
	preload("res://world/EntranceBuilder.gd").build(self)
	preload("res://world/ForestConnectorBuilder.gd").build(self)

func strip(a: Vector3, b: Vector3, c: Vector3, d: Vector3, color: Color, solid: bool, parent: Node3D = self) -> MeshInstance3D:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Both route and outward end caps must face upward despite opposite vertex ordering.
	var vertices: Array = [a,c,b,a,d,c] if (b-a).cross(c-a).y > 0 else [a,b,c,a,c,d]
	for vertex: Vector3 in vertices:
		surface.add_vertex(vertex)
	surface.generate_normals()
	var result := Kit.mesh(parent,surface.commit(),Vector3.ZERO,color)
	result.material_override = result.material_override.duplicate()
	result.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	if solid:
		result.create_trimesh_collision()
	return result

func beam(a: Vector3, b: Vector3, width: float, height: float, color: Color, solid: bool = false) -> Node3D:
	var holder := Node3D.new()
	holder.position = (a+b)*0.5
	add_child(holder)
	holder.look_at_from_position(holder.position,b,Vector3.UP)
	Kit.box(holder,Vector3.ZERO,Vector3(width,height,a.distance_to(b)+0.05),color,solid)
	return holder

func _build_land() -> void:
	for i in range(Layout.POINTS.size()-1):
		var a: Vector3 = Layout.POINTS[i]
		var b: Vector3 = Layout.POINTS[i+1]
		var ra := Layout.right_at(i)
		var rb := Layout.right_at(i+1)
		strip(a-ra*4.0-Vector3.UP*0.08,a+ra*23-Vector3.UP*0.08,b+rb*23-Vector3.UP*0.08,b-rb*4-Vector3.UP*0.08,Color("8b9e70"),true).set_meta("semantic_id","Grass_Bank")
		var wood := i > 0 and i < 4
		strip(a-ra*Layout.HALF_WIDTH,a+ra*Layout.HALF_WIDTH,b+rb*Layout.HALF_WIDTH,b-rb*Layout.HALF_WIDTH,Color("956951") if wood else Color("b9b9ad"),true).set_meta("semantic_id","FairyLake_Path_%02d" % (i+1))
		strip(a+ra*10,a+ra*18,b+rb*18,b+rb*10,Color("8b9290"),false).set_meta("semantic_id","Road_01")
		# Thin joints follow the exact same sloped surface rather than flat floating cubes.
		var divisions := int(a.distance_to(b)/(0.7 if wood else 2.6))
		for j in range(1,divisions):
			var t := float(j)/divisions
			var p := a.lerp(b,t)+Vector3.UP*0.016
			var right := ra.lerp(rb,t)
			beam(p-right*2.78,p+right*2.78,0.025,0.012,Color("70523f") if wood else Color("989f97"))
		# Visible lake rail and land-side hedge define a safe, finite playable strip.
		var edge_a := a-ra*3.25
		var edge_b := b-rb*3.25
		var rail_body := beam(edge_a+Vector3.UP*0.7,edge_b+Vector3.UP*0.7,0.13,1.4,Color("657a74"),true)
		rail_body.set_meta("semantic_id","Railing_01")
		beam(edge_a+Vector3.UP*1.43,edge_b+Vector3.UP*1.43,0.2,0.14,Color("75513d"))
		# Rail infill is rendered as individual balusters; collider is transparent.
		for child in rail_body.get_children():
			if child is MeshInstance3D:
				child.visible = false
		for j in range(divisions+1):
			var p := edge_a.lerp(edge_b,float(j)/divisions)
			Kit.cylinder(self,p+Vector3.UP*0.7,0.055,1.4,Color("71867c"))
		beam(a+ra*7+Vector3.UP*0.65,b+rb*7+Vector3.UP*0.65,1.0,1.3,Color("657e57"),true)
		for j in range(3):
			var t := (j+0.35)/3.0
			var p := a.lerp(b,t)+ra.lerp(rb,t)*8.8
			Kit.tree(semantic_nodes.TreeBelt_01,p,7.6+float((i+j)%3))
			Kit.tree(semantic_nodes.TreeBelt_01,p+ra.lerp(rb,t)*12,8.0+float(i%2))
		# Lake-side bank drops to the water; this elevation profile remains a placeholder.
		strip(a-ra*4,b-rb*4,Vector3(b.x-rb.x*7,-0.7,b.z-rb.z*7),Vector3(a.x-ra.x*7,-0.7,a.z-ra.z*7),Color("7b8562"),false)
	# End fences stay beyond entry/exit targets and bound the continuous terrain.
	for i in [Layout.POINTS.size()-1]:
		var p: Vector3 = Layout.POINTS[i]
		var r := Layout.right_at(i)
		var outward := Vector3(-r.z,0,r.x) * (1 if i == 0 else -1)
		strip(p-r*4,p+r*23,p+r*23+outward*4,p-r*4+outward*4,Color("b9b9ad"),true)
		beam(p-r*3.25+outward*2.4+Vector3.UP*0.7,p+r*7+outward*2.4+Vector3.UP*0.7,0.3,1.4,Color("657e57"),true)
		beam(p-r*3.25,p-r*3.25+outward*2.4,0.2,2.8,Color("657e57"),true)
		beam(p+r*7,p+r*7+outward*2.4,0.5,2.8,Color("657e57"),true)
		# Visual continuation beyond the fenced slice, never a playable/global connector.
		strip(p-r*4+outward*4,p+r*23+outward*4,p+r*23+outward*42,p-r*4+outward*42,Color("82916a"),false)
		var paving_lift := Vector3.UP*0.02
		strip(p-r*2.8+outward*4+paving_lift,p+r*2.8+outward*4+paving_lift,p+r*2.8+outward*42+paving_lift,p-r*2.8+outward*42+paving_lift,Color("b9b9ad"),false)
		for j in range(4):
			Kit.tree(self,p+r*8+outward*(9+j*8),8.0)

func _build_water() -> void:
	var lake: Node3D = semantic_nodes.FairyLake
	Kit.box(lake,Vector3.ZERO,Vector3(100,0.15,260),Color("4c8280"))
	# Low contrast reflected bands, no downloaded texture or opaque blue ground plane.
	for i in range(21):
		Kit.box(lake,Vector3(-12+(i%4)*8,0.085,-65+i*6),Vector3(8+(i%3)*4,0.015,0.1),Color("72aaa5"))
	for i in range(9):
		var hill := SphereMesh.new()
		hill.radius = 20
		hill.height = 40
		hill.radial_segments = 9
		hill.rings = 4
		var mound := Kit.mesh(semantic_nodes.HillBackdrop,hill,Vector3(-72-i%3*6,-9,-90+i*24),Color("657f6b") if i%2 else Color("728875"))
		mound.scale = Vector3(1.0,0.65+(i%3)*0.1,1.4)
	for i in range(6):
		var hill := SphereMesh.new()
		hill.radius = 23
		hill.height = 46
		hill.radial_segments = 9
		hill.rings = 4
		var mound := Kit.mesh(semantic_nodes.HillBackdrop,hill,Vector3(-65+i*18,-6,-111-(i%2)*8),Color("728c79"))
		mound.scale = Vector3(1.15,0.7+(i%3)*0.12,1.0)
	for i in range(3):
		Kit.box(semantic_nodes.BuildingBackdrop,Vector3(i*8,4,-i*8),Vector3(7,8,10),Color("ccd1c3"))

func physical_text(parent: Node3D, words: String, p: Vector3, size: int = 42) -> void:
	var label := Kit.label(parent,words,p,size)
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label.no_depth_test = false
	label.pixel_size = 0.013
	label.outline_size = 1

func _build_landmarks() -> void:
	var stone: Node3D = semantic_nodes.Sign_01
	var rock := SphereMesh.new()
	rock.radius = 1.5
	rock.height = 3
	rock.radial_segments = 7
	rock.rings = 3
	var rock_mesh := Kit.mesh(stone,rock,Vector3(0,1.9,0),Color("b4aba0"))
	rock_mesh.scale = Vector3(0.7,1.35,0.6)
	rock_mesh.create_trimesh_collision()
	physical_text(stone,"神\n仙\n湖",Vector3(0,1.9,0.96),40)
	stone.get_child(stone.get_child_count()-1).modulate = Color("365e50")
	for id: String in ["UpperCampus_Direction","LowerCampus_Direction"]:
		var node: Node3D = semantic_nodes[id]
		Kit.cylinder(node,Vector3(4.2,1.35,0),0.1,2.7,Color("655746"))
		Kit.box(node,Vector3(4.2,2.5,0),Vector3(3.4,1.25,0.16),Color("325c51"),true)
		physical_text(node,"上园方向\n神仙湖步道 ↓" if id.begins_with("Upper") else "下园方向 →\n本段步道终点",Vector3(4.2,2.55,0.1),30)
	var pavilion: Node3D = semantic_nodes.Pavilion_01
	Kit.cylinder(pavilion,Vector3(0,-0.7,0),3.1,1.5,Color("8b9b8d"))
	Kit.cylinder(pavilion,Vector3(0,-0.05,0),3.3,0.4,Color("b4b5a6"))
	for i in range(8):
		var angle := TAU*i/8.0
		Kit.cylinder(pavilion,Vector3(cos(angle)*2.5,2.2,sin(angle)*2.5),0.17,4.4,Color("dddcc9"))
	Kit.cylinder(pavilion,Vector3(0,4.4,0),3.2,0.3,Color("d8d9ca"))
	var dome := SphereMesh.new()
	dome.radius = 3.1
	dome.height = 6.2
	dome.is_hemisphere = true
	dome.radial_segments = 16
	dome.rings = 6
	var roof := Kit.mesh(pavilion,dome,Vector3(0,4.5,0),Color("c4c9bd"))
	roof.scale.y = 0.45
	var bench: Node3D = semantic_nodes.Bench_01
	Kit.box(bench,Vector3(0,0.75,0),Vector3(2.5,0.18,0.8),Color("79553f"),true)
	Kit.box(bench,Vector3(0,1.25,-0.35),Vector3(2.5,0.7,0.12),Color("79553f"),true)
	for x in [-0.9,0.9]:
		Kit.box(bench,Vector3(x,0.35,0),Vector3(0.15,0.7,0.65),Color("495c55"))
	for i in [1,3,4]:
		var lamp: Node3D = semantic_nodes["Lamp_%02d" % i]
		Kit.cylinder(lamp,Vector3.UP*2.5,0.08,5,Color("4f6159"))
		var lamp_body := StaticBody3D.new()
		lamp_body.position.y = 2.5
		var lamp_collision := CollisionShape3D.new()
		var lamp_shape := CylinderShape3D.new()
		lamp_shape.radius = 0.12
		lamp_shape.height = 5
		lamp_collision.shape = lamp_shape
		lamp_body.add_child(lamp_collision)
		lamp.add_child(lamp_body)
		Kit.box(lamp,Vector3.UP*5,Vector3(0.8,0.22,0.65),Color("dddac1"))
	var stop: Node3D = semantic_nodes.UpperCampus_BusStop
	Kit.cylinder(stop,Vector3(0,1.5,0),0.08,3,Color("68796c"))
	Kit.box(stop,Vector3(0,2.7,0),Vector3(2.5,1.3,0.12),Color("808a77"))
	physical_text(stop,"接驳候车点\n尚未开放",Vector3(0,2.7,0.08),28)
