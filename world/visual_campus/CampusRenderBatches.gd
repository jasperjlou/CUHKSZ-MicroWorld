extends RefCounted
## Static opaque unit-box instances only. Keep collision bodies and transparent sorting intact.
static func build(world:Node3D)->Dictionary:
	var cells:Dictionary={};var originals:Array[MultiMeshInstance3D]=[];var count:=0
	for node:Node in world.find_children("*","MultiMeshInstance3D",true,false):
		var source:MultiMeshInstance3D=node
		var mm:MultiMesh=source.multimesh
		if not source.is_visible_in_tree() or mm==null or not mm.mesh is BoxMesh:continue
		if mm.mesh.size!=Vector3.ONE or mm.use_colors or mm.use_custom_data:continue
		if not source.material_override is ShaderMaterial:continue
		if source.visibility_range_end>0 or source.visibility_range_begin>0:continue
		var material:Material=source.material_override
		for i in mm.instance_count:
			var transform:Transform3D=source.global_transform*mm.get_instance_transform(i)
			var cell:=Vector3i(floori(transform.origin.x/48),floori(transform.origin.y/24),floori(transform.origin.z/48))
			var key:=str(material.get_instance_id())+":"+str(source.cast_shadow)+":"+str(cell)
			if not cells.has(key):cells[key]={"origin":Vector3(cell.x*48+24,cell.y*24+12,cell.z*48+24),"transforms":[],"material":material,"shadow":source.cast_shadow}
			transform.origin-=cells[key].origin;cells[key].transforms.append(transform);count+=1
		originals.append(source)
	var holder:=Node3D.new();holder.name="StaticOpaqueBoxBatchesV185";world.add_child(holder)
	var shared:=BoxMesh.new();shared.size=Vector3.ONE
	var packed:=0
	for key:String in cells:
		var cell:Dictionary=cells[key];var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.mesh=shared;mm.instance_count=cell.transforms.size()
		for i in mm.instance_count:mm.set_instance_transform(i,cell.transforms[i])
		var node:=MultiMeshInstance3D.new();node.multimesh=mm;node.material_override=cell.material;node.cast_shadow=cell.shadow;holder.add_child(node);node.global_position=cell.origin
		packed+=mm.instance_count
	# Preserve authored nodes/paths for tools. All original physical bodies are siblings.
	for node:MultiMeshInstance3D in originals:node.hide()
	var report:Dictionary={"source_batches":originals.size(),"spatial_batches":cells.size(),"instances_before":count,"instances_after":packed,"collision_changed":false}
	world.set_meta("render_batch_report",report);return report
