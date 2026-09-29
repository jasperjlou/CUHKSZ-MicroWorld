extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func collisions(node: Node, result: Array) -> void:
	if node is CollisionShape3D:
		result.append([node.get_path(),node.global_transform,node.shape,node.disabled])
	for child in node.get_children():
		collisions(child,result)

func run() -> void:
	var builder := preload("res://world/FairyLakeBuilder.gd").new()
	root.add_child(builder)
	await physics_frame
	var before: Array = []
	collisions(builder,before)
	var semantics: Array = []
	for key: String in builder.semantic_nodes:
		var node: Node3D = builder.semantic_nodes[key]
		semantics.append([key,node.global_transform,node.get_meta("semantic").duplicate(true)])
	preload("res://world/LakeReferenceDetails.gd").apply(builder)
	var after: Array = []
	collisions(builder,after)
	var failures: Array[String] = []
	if before != after:
		failures.append("Appearance layer changed collision shapes, transforms or enable state")
	for record: Array in semantics:
		var node: Node3D = builder.semantic_nodes[record[0]]
		if node.global_transform != record[1] or node.get_meta("semantic") != record[2]:
			failures.append("Changed semantic anchor "+str(record[0]))
	var slab: MeshInstance3D = builder.semantic_nodes.Sign_01.get_node("FieldPhotoDetails/WarmInscriptionSlab")
	var arrays := slab.mesh.surface_get_arrays(0)
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	if normals[0].z < 0.9:
		failures.append("Inscription face points inward")
	print("FIELD DETAILS QA: ",JSON.stringify({"colliders_before":before.size(),"colliders_after":after.size(),"semantic_anchors":semantics.size(),"failures":failures}))
	quit(0 if failures.is_empty() else 1)
