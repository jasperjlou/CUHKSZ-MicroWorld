extends RefCounted
static func build(world: Node3D) -> Node3D:
	var root:=Node3D.new();root.name="ConfidenceHeatmap";root.visible=false;world.add_child(root)
	var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/campus_accuracy_v4.json"))
	for record: Dictionary in data.records:
		if not world.objects.has(record.id):continue
		var object: Node3D=world.objects[record.id];var spatial: Dictionary=object.get_meta("spatial_record")
		var material:=StandardMaterial3D.new();material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color=Color("6cbb92") if record.current_confidence=="SUPPORTED" else Color("d47a69") if record.current_confidence=="PLACEHOLDER" else Color("d2ad64")
		var mesh:=BoxMesh.new();mesh.size=Vector3(spatial.footprint_width,.25,spatial.footprint_depth)
		var node:=MeshInstance3D.new();node.mesh=mesh;node.material_override=material;node.position=object.position+Vector3.UP*(spatial.estimated_height+2);root.add_child(node)
	return root
