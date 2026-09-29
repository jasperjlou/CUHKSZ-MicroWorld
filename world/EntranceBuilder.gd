extends RefCounted
const Layout := preload("res://world/EntranceLayout.gd")
const Kit := preload("res://world/MeshKit.gd")
const Planter := preload("res://assets/campus/SquareTreePlanter.tscn")
const Terrace := preload("res://assets/campus/GraniteTerrace.tscn")

static func build(builder: Node3D) -> void:
	for record: Dictionary in Layout.objects():
		var marker: Node3D = Planter.instantiate() if record.get("asset_id","") == "square_tree_planter" else (Terrace.instantiate() if record.get("asset_id","") == "granite_terrace" else Node3D.new())
		marker.name = record.id+"__inferred"
		marker.position = Vector3(record.position[0],record.position[1],record.position[2])
		marker.set_meta("semantic",record.duplicate(true))
		marker.add_to_group("lake_semantics")
		builder.add_child(marker)
		builder.semantic_nodes[record.id] = marker
	for i in range(Layout.POINTS.size()-1):
		var a: Vector3 = Layout.POINTS[i]
		var b: Vector3 = Layout.POINTS[i+1]
		var ra := Layout.right_at(i)
		var rb := Layout.right_at(i+1)
		# One shared upward collision strip; the original entry cross-section remains unchanged.
		builder.strip(a-ra*12,a+ra*12,b+rb*12,b-rb*12,Color("acb5af"),true)
		# Shared cross-sections prevent bend cracks; land shoulders hide the water underlay.
		for side: float in [-1,1]:
			builder.strip(a+ra*side*12,a+ra*side*28-Vector3.UP*0.35,b+rb*side*28-Vector3.UP*0.35,b+rb*side*12,Color("7e966e"),false)
			builder.strip(a+ra*side*28-Vector3.UP*0.35,a+ra*side*28-Vector3.UP*4,b+rb*side*28-Vector3.UP*4,b+rb*side*28-Vector3.UP*0.35,Color("798661"),false)
		for j in range(int(a.distance_to(b)/2)):
			var t := (j+0.5)/float(int(a.distance_to(b)/2))
			var p := a.lerp(b,t)+Vector3.UP*0.014
			var right := ra.lerp(rb,t)
			builder.beam(p-right*11.8,p+right*11.8,0.025,0.015,Color("939f99"))
		for offset: float in [-9,-6,-3,0,3,6,9]:
			builder.beam(a+ra*offset+Vector3.UP*0.016,b+rb*offset+Vector3.UP*0.016,0.02,0.014,Color("9da8a1"))
		# Low solid planting edges define bounded public space, outside the route centerline.
		for side: float in [-1,1]:
			builder.beam(a+ra*side*12+Vector3.UP*0.45,b+rb*side*12+Vector3.UP*0.45,0.4,0.9,Color("7d9475"),true)
			for j in range(2):
				var t := (j+0.4)/2
				var p := a.lerp(b,t)+ra.lerp(rb,t)*side*13.4
				Kit.tree(builder,p,6.5+j)
	# Phase B reuses the shared end cross-section; only the lower terrain remains.
	var end: Vector3 = Layout.POINTS[-1]
	var right := Layout.right_at(Layout.POINTS.size()-1)
	var forward := Vector3(-right.z,0,right.x)
	builder.strip(end-right*28-Vector3.UP*0.08,end+right*28-Vector3.UP*0.08,end+right*28+forward*26-Vector3.UP*0.35,end-right*28+forward*26-Vector3.UP*0.35,Color("7e966e"),false)
