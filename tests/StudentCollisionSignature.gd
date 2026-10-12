extends RefCounted
static func capture(world:Node)->Dictionary:
	var student:=world.get_node("student_centre")
	var records:Array[String]=[]
	for node in student.find_children("*","CollisionShape3D",true,false):
		var shape:Shape3D=node.shape
		var content:Variant
		if shape is BoxShape3D:content=shape.size
		elif shape is ConcavePolygonShape3D:content=shape.get_faces()
		else:content=var_to_str(shape)
		records.append(var_to_str([shape.get_class(),node.global_transform,content,node.disabled,node.get_parent().collision_layer,node.get_parent().collision_mask]).sha256_text())
	records.sort()
	return {"shape_count":records.size(),"sha256":var_to_str(records).sha256_text()}
