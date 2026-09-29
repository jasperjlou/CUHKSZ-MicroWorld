extends Node3D
const Kit := preload("res://world/MeshKit.gd")
@export var asset_kind := "square_tree_planter"

func _ready() -> void:
	set_meta("asset_id",asset_kind)
	set_meta("authored_version","1.0.0-phase-a")
	set_meta("source_reference","VR_42078153")
	set_meta("confidence",{"presence":"verified","dimensions":"inferred","elevation":"placeholder"})
	if asset_kind == "square_tree_planter":
		Kit.box(self,Vector3(0,0.25,0),Vector3(3.5,0.5,3.5),Color("acb3ad"),true)
		Kit.box(self,Vector3(0,0.52,0),Vector3(2.85,0.06,2.85),Color("718768"))
		Kit.cylinder(self,Vector3(0,3.4,0),0.24,6.2,Color("b1b8aa"))
		for i in range(3):
			var crown := SphereMesh.new()
			crown.radius = 1.85
			crown.height = 2.8
			crown.radial_segments = 7
			crown.rings = 3
			Kit.mesh(self,crown,Vector3((i-1)*1.25,7.0+float(i%2),0.6*(i%2)),Color("68896b") if i%2 else Color("759478"))
	elif asset_kind == "granite_terrace":
		# Raised landing gives the steps a destination rather than a freestanding wedge.
		Kit.box(self,Vector3(0,0.27,-4.5),Vector3(5,0.54,3),Color("adb5b0"),true)
		Kit.box(self,Vector3(0,0.59,-5.8),Vector3(5,0.1,0.4),Color("849b73"))
		for i in range(3):
			Kit.box(self,Vector3(0,0.09+0.18*i,-0.5-i),Vector3(5,0.18,3-i),Color("adb5b0"))
		# Shared production collider approximates the risers, avoiding engine-specific step snapping.
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		for p: Vector3 in [Vector3(-2.5,0,1),Vector3(2.5,0.54,-3),Vector3(-2.5,0.54,-3),Vector3(-2.5,0,1),Vector3(2.5,0,1),Vector3(2.5,0.54,-3)]:
			surface.add_vertex(p)
		surface.generate_normals()
		var collision := Kit.mesh(self,surface.commit(),Vector3.ZERO,Color("aab4af"))
		collision.create_trimesh_collision()
		collision.visible = false
