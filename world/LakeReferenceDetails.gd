extends RefCounted
## Appearance-only overlay. Original colliders, semantic records and route stay intact.
const Kit := preload("res://world/MeshKit.gd")

static func apply(builder: Node3D) -> void:
	var stone: Node3D = builder.semantic_nodes.Sign_01
	for child in stone.get_children():
		if child is MeshInstance3D:
			# Hiding the old render mesh does not disable its child StaticBody3D.
			child.visible = false
		elif child is Label3D:
			child.position = Vector3(0,2.05,0.65)
			child.modulate = Color("397a47")
			child.outline_size = 0
	var detail := Node3D.new()
	detail.name = "FieldPhotoDetails"
	stone.add_child(detail)
	build_stone(detail)
	build_garden(detail)
	# Existing lamp anchors remain illustrative, not surveyed photo locations.
	for id: String in ["Lamp_01","Lamp_03","Lamp_04"]:
		var lamp: Node3D = builder.semantic_nodes[id]
		for child in lamp.get_children():
			if child is MeshInstance3D:
				child.visible = false
		Kit.cylinder(lamp,Vector3(0,2.5,0),0.07,5,Color("c0c5bd"))
		Kit.box(lamp,Vector3(0.28,4.93,0),Vector3(0.65,0.09,0.11),Color("858e87"))
		var cap := Kit.box(lamp,Vector3(0.51,4.87,0),Vector3(0.38,0.07,0.25),Color("eee1b9"))
		cap.material_override = Kit.material(Color("eee1b9"),true)

static func build_stone(parent: Node3D) -> void:
	# Broad flat letter face with irregular silhouette, referenced to photos 334–336.
	var outline: Array[Vector2] = [Vector2(-0.85,0.13),Vector2(0.86,0.13),Vector2(0.96,1.18),Vector2(0.81,2.95),Vector2(0.49,3.86),Vector2(0.06,4.0),Vector2(-0.62,3.53),Vector2(-0.91,2.26)]
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(outline.size()):
		var a := outline[i]
		var b := outline[(i+1)%outline.size()]
		for v: Vector3 in [Vector3(0,2,0.59),Vector3(b.x,b.y,0.59),Vector3(a.x,a.y,0.59),Vector3(0,2,-0.52),Vector3(a.x,a.y,-0.52),Vector3(b.x,b.y,-0.52),Vector3(a.x,a.y,0.59),Vector3(b.x,b.y,-0.52),Vector3(a.x,a.y,-0.52),Vector3(a.x,a.y,0.59),Vector3(b.x,b.y,0.59),Vector3(b.x,b.y,-0.52)]:
			surface.add_vertex(v)
	surface.generate_normals()
	var rock := Kit.mesh(parent,surface.commit(),Vector3.ZERO,Color("c3ae78"))
	rock.name = "WarmInscriptionSlab"
	# Muted mineral facets, clear of the inscription; no photographic texture reuse.
	var facet := Kit.box(parent,Vector3(-0.69,1.85,0.602),Vector3(0.09,2.7,0.015),Color("b09a68"))
	facet.rotation.z = -0.09

static func pebble_mesh() -> SphereMesh:
	var shape := SphereMesh.new()
	shape.radius = 1
	shape.height = 2
	shape.radial_segments = 6
	shape.rings = 3
	return shape

static func build_garden(parent: Node3D) -> void:
	var random := RandomNumberGenerator.new()
	random.seed = 929334
	Kit.box(parent,Vector3(0,0.01,0.08),Vector3(3.25,0.12,2.25),Color("a5a79a"))
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.use_colors = true
	multi.mesh = pebble_mesh()
	multi.instance_count = 230
	for i in range(multi.instance_count):
		var p := Vector3(random.randf_range(-1.58,1.58),0.095,random.randf_range(-0.98,1.14))
		var size := random.randf_range(0.055,0.11)
		multi.set_instance_transform(i,Transform3D(Basis.from_scale(Vector3(size,size*0.5,size*0.8)),p))
		multi.set_instance_color(i,Color("c0c1af").darkened(random.randf_range(0,0.23)))
	var gravel := MultiMeshInstance3D.new()
	gravel.multimesh = multi
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 1
	gravel.material_override = mat
	parent.add_child(gravel)
	for p: Vector3 in [Vector3(-1.1,0.23,0.87),Vector3(0.78,0.22,0.98),Vector3(1.13,0.27,-0.53)]:
		var rock := Kit.mesh(parent,pebble_mesh(),p,Color("b8a779"))
		rock.scale = Vector3(0.38,0.23,0.3)
	# Garden stays behind the existing railing, outside the playable path.
	for i in range(7):
		var shrub := Kit.mesh(parent,pebble_mesh(),Vector3(-1.15+i*0.38,0.48,-0.91),Color("506e45") if i%2 else Color("648352"))
		shrub.scale = Vector3(0.48,0.52+0.1*(i%3),0.42)
	Kit.box(parent,Vector3(-0.88,0.16,1.0),Vector3(0.28,0.24,0.22),Color("38413b"))
	var face := Kit.box(parent,Vector3(-0.88,0.3,0.98),Vector3(0.23,0.035,0.17),Color("e8dcb0"))
	face.material_override = Kit.material(Color("e8dcb0"),true)
	var light := SpotLight3D.new()
	light.position = Vector3(-0.88,0.38,1.03)
	light.rotation_degrees = Vector3(58,0,0)
	light.light_color = Color("ffedc3")
	light.light_energy = 0.65
	light.spot_range = 5
	light.spot_angle = 42
	light.shadow_enabled = false
	parent.add_child(light)
