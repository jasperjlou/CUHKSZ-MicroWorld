extends RefCounted
const Kit := preload("res://world/MeshKit.gd")
const Layout := preload("res://world/JourneyLayout.gd")
const Junction := preload("res://world/JunctionLayout.gd")
const Builder := preload("res://world/JunctionBuilder.gd")

static func build(builder: Node3D) -> void:
	var root := Node3D.new()
	root.name = "JourneyDestinationSlices"
	builder.add_child(root)
	for record: Dictionary in Layout.objects():
		var area := Node3D.new()
		area.name = record.id
		area.position = Vector3(record.position[0],record.position[1],record.position[2])
		area.set_meta("semantic",record.duplicate(true))
		area.add_to_group("lake_semantics")
		root.add_child(area)
		builder.semantic_nodes[record.id] = area
		var upper: bool = record.id == "UpperCampus_Start"
		if not upper:
			area.rotation.y = atan2(18.0,-13.0)
		# Existing radius-seven plaza and its continuous collision are retained.
		# Furniture stays off the centre and the incoming road; no new terrain shortcut.
		for x: float in [-3.8,3.8]:
			Kit.box(area,Vector3(x,0.65,2.6),Vector3(1.8,1.3,1.5),Color("aaa995"),true)
			Kit.box(area,Vector3(x,1.35,2.6),Vector3(1.65,0.18,1.35),Color("718760"))
			Kit.box(area,Vector3(x,0.6,-2.1),Vector3(1.6,0.18,0.65),Color("a89c7d"),true)
		# Flat paving joints reveal the usable plaza without raising collider seams.
		for x: float in [-2,0,2]:
			Kit.box(area,Vector3(x,0.045,0),Vector3(0.035,0.01,7),Color("929e92"))
		var sign := Vector3(-4.2,2.8,2.6) if upper else Vector3(0,2.8,4.7)
		var width := 3.8 if upper else 6.0
		Kit.box(area,sign,Vector3(width,1.1,0.25),Color("426b5b"))
		for x: float in [-1,1]:
			Kit.box(area,sign+Vector3(x*(width/2-0.3),-1.4,0),Vector3(0.22,2.8,0.25),Color("8e9a89"),true)
		Builder.double_sided_text(builder,area,"上园 · 出发广场" if upper else "下园 · 校园交流会","上园 · 出发广场" if upper else "下园 · 校园交流会",sign,0.15,24 if upper else 27)
		if not upper:
			Kit.label(area,"活动签到处\n走近后按 [E] 签到",Vector3(0,1.5,3),20)
		# Background massing only; no invented building name or accessible interior.
		background(area,Vector3(0,-0.15,32 if upper else 15),upper)
		for side: float in [-1,1]:
			Kit.tree(area,Vector3(side*10,0,10),5.5)
		Builder.stamp(area,record)
	var ling := Node3D.new()
	ling.name = "LingCollegeBackdrop"
	ling.position = Junction.point("LingCollege_Approach")
	root.add_child(ling)
	background(ling,Vector3(0,-0.15,17),true)
	# Shallow display steps behind the gate; entry stays bounded at the existing rim.
	for i in range(3):
		Kit.box(ling,Vector3(0,0.08+i*0.12,5+i*0.5),Vector3(5.4,0.16+i*0.24,0.55),Color("b5b7a6"))
	Builder.stamp(ling,Layout.definition().landmark)

static func background(parent: Node3D,p: Vector3,upper: bool) -> void:
	var height := 10.0 if upper else 6.5
	Kit.box(parent,p+Vector3.UP*height/2,Vector3(16,height,5),Color("c4c5b3"))
	Kit.box(parent,p+Vector3(0,1.4,-2.6),Vector3(16,2.8,0.25),Color("9e8069"))
	for x in range(-6,7,3):
		for y in range(4,int(height),2):
			Kit.box(parent,p+Vector3(x,y,-2.56),Vector3(1.35,1.1,0.12),Color("749598"))
	Kit.box(parent,p+Vector3(0,height+0.12,0),Vector3(16.5,0.24,5.5),Color("a5ac9d"))
